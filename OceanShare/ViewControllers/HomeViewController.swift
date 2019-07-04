//
//  HomeViewController.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 28/12/2018.
//  Copyright © 2018 Joseph Pereniguez. All rights reserved.
//

import UIKit
import Mapbox
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore
import FirebaseStorage
import FirebasePerformance
import JJFloatingActionButton

class HomeViewController: UIViewController, MGLMapViewDelegate {
    
    // MARK: - Firebase
    
    var ref: DatabaseReference!
    let storageRef = FirebaseStorage.Storage().reference()
    
    // MARK: - Variables
    
    // view
    var effect: UIVisualEffect!
    var viewStacked: UIView?
    var overViewStacked: UIView?
    
    // tag properties
    var Tag_properties = Tag(description: "", id: 0, latitude: 0.0, longitude: 0.0, time: "", user: "")
    var Tags_ids = [String]()
    var Tags_hashs = [Int]()
    
    // tag globals
    var selectedTag: MGLAnnotation?
    var selectedTagId: String?
    var selectedTagUserId: String?
    var selectedTagUserName: String?
    
    // map properties
    var cordinate: CLLocationCoordinate2D!
    var mapView: MGLMapView!
    var isInside = false
    
    // MARK: - Outlets
    
    // icon view
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var closeIcon: UIImageView!
    @IBOutlet weak var buttonMenu: DesignableButton!
    
    // comment view
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    // description view
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var thumbDownView: DesignableView!
    @IBOutlet weak var thumbDownIcon: UIImageView!
    @IBOutlet weak var thumbUpView: DesignableView!
    @IBOutlet weak var thumbUpIcon: UIImageView!
    @IBOutlet weak var editIcon: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var closeDescriptionIcon: UIImageView!
    
    // edition view
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var editionView: UIView!
    @IBOutlet weak var newDescriptionTextField: UITextField!
    
    // wheater icon view
    @IBOutlet weak var weatherIconView: UIView!
    @IBOutlet weak var airTemperatureLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var rainRiskLabel: UILabel!
    @IBOutlet weak var waterTemperatureLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var visibilityLabel: UILabel!
    @IBOutlet weak var uvLabel: UILabel!
    
    // visual effect
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference().child("markers")
        SyncData()
        
        // define the MLG map view and the user on this map
        setupView()
        
        // setup the visual effect
        effect = visualEffectView.effect
        visualEffectView.effect = nil
        visualEffectView.isHidden = true
        
    }
    
    // MARK: - Setup
    
    func setupView() {
        // mapview setup
        mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        
        // enable heading tracking mode (arrow will appear)
        mapView.userTrackingMode = .followWithHeading
        
        // enable the permanent heading indicator which will appear when the tracking mode is not `.followWithHeading`.
        mapView.showsUserHeadingIndicator = true
        getTagsFromServer(mapView: mapView)
        
        // setup textfields
        self.descriptionTextField.maxLength = 75
        self.newDescriptionTextField.maxLength = 75
        
        // icon setup
        self.setupCustomIcons()
        
        // add the layers in the right order
        view.addSubview(mapView)
        view.addSubview(headerView)
        view.addSubview(buttonMenu)
        view.addSubview(visualEffectView)
        
    }
    
    func setupCustomIcons() {
        // icon view
        self.closeIcon.image = self.closeIcon.image!.withRenderingMode(.alwaysTemplate)
        self.closeIcon.tintColor = UIColor(rgb: 0x000000)
        
        // description view
        self.editIcon.image = self.editIcon.image!.withRenderingMode(.alwaysTemplate)
        self.editIcon.tintColor = UIColor(rgb: 0xC5C7D2)
        self.closeDescriptionIcon.image = self.closeDescriptionIcon.image!.withRenderingMode(.alwaysTemplate)
        self.closeDescriptionIcon.tintColor = UIColor(rgb: 0x000000)
        self.thumbUpIcon.image = self.thumbUpIcon.image!.withRenderingMode(.alwaysTemplate)
        self.thumbUpIcon.tintColor = UIColor(rgb: 0x606060)
        self.thumbDownIcon.image = self.thumbDownIcon.image!.withRenderingMode(.alwaysTemplate)
        self.thumbDownIcon.tintColor = UIColor(rgb: 0x606060)
        
    }
    
    // MARK: - Animations
    
    func animateInWithOptionalEffect(view: UIView, effect: Bool) {
        if effect == true {
            visualEffectView.isHidden = false
            
        }
        self.view.addSubview(view)
        view.center = self.view.center
        
        view.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        view.alpha = 0
        
        
        UIView.animate(withDuration: 0.4) {
            if effect == true {
                self.visualEffectView.effect = self.effect
                self.visualEffectView.alpha = 0.8
                
            }
            view.alpha = 1
            view.transform = CGAffineTransform.identity
        }
    }
    
    func animateOutWithOptionalEffect(effect: Bool) {
        UIView.animate(withDuration: 0.3, animations: {
            if effect == true {
                self.viewStacked!.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                self.viewStacked!.alpha = 0
                self.visualEffectView.effect = nil

            } else {
                self.overViewStacked!.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                self.overViewStacked!.alpha = 0
                
            }
        }) { (success:Bool) in
            if effect == true {
                self.viewStacked!.removeFromSuperview()
                self.visualEffectView.isHidden = true
                
            } else {
                self.overViewStacked!.removeFromSuperview()
                
            }
        }
    }
    
    // MARK: - Menu Icon View
    
    @IBAction func closeMenu(_ sender: Any) {
        self.animateOutWithOptionalEffect(effect: true)
        
    }
    
    @IBAction func openMenu(_ sender: Any) {
        self.viewStacked = iconView
        self.animateInWithOptionalEffect(view: iconView, effect: true)
        
    }
    
    @IBAction func medusaActivate(_ sender: Any) {
        Tag_properties.id = 0
        Tag_properties.description = "Jellyfishs"
        Tag_properties.time = getCurrentTime()
        Tag_properties.user = getCurrentUser()
        self.isPressable(activate: true)
        self.animateOutWithOptionalEffect(effect: true)
        
    }
    
    @IBAction func diverActivate(_ sender: Any) {
        Tag_properties.id = 1
        Tag_properties.description = "Divers"
        Tag_properties.time = getCurrentTime()
        Tag_properties.user = getCurrentUser()
        self.isPressable(activate: true)
        self.animateOutWithOptionalEffect(effect: true)

    }
    
    @IBAction func wasteActivate(_ sender: Any) {
        Tag_properties.id = 2
        Tag_properties.description = "Waste"
        Tag_properties.time = getCurrentTime()
        Tag_properties.user = getCurrentUser()
        self.isPressable(activate: true)
        self.animateOutWithOptionalEffect(effect: true)

    }
    
    @IBAction func warningActivate(_ sender: Any) {
        Tag_properties.id = 3
        Tag_properties.description = "Warning"
        Tag_properties.time = getCurrentTime()
        Tag_properties.user = getCurrentUser()
        self.isPressable(activate: true)
        self.animateOutWithOptionalEffect(effect: true)

    }
    
    @IBAction func dolphinActivate(_ sender: Any) {
        Tag_properties.id = 4
        Tag_properties.description = "Dolphins"
        Tag_properties.time = getCurrentTime()
        Tag_properties.user = getCurrentUser()
        self.isPressable(activate: true)
        self.animateOutWithOptionalEffect(effect: true)

    }
    
    @IBAction func destinationActivate(_ sender: Any) {
        Tag_properties.id = 5
        Tag_properties.description = "Destination"
        Tag_properties.time = getCurrentTime()
        Tag_properties.user = getCurrentUser()
        self.isPressable(activate: true)
        self.animateOutWithOptionalEffect(effect: true)

    }
    
    @IBAction func weatherActivate(_ sender: Any) {
        // TODO: add the weather event
        self.isPressable(activate: true)
        self.animateOutWithOptionalEffect(effect: true)

    }
    
    // MARK: - Description View
    
    @IBAction func closeDescription(_ sender: Any) {
        self.animateOutWithOptionalEffect(effect: true)
    }
    
    @IBAction func downVoteEvent(_ sender: Any) {
        self.thumbDownView.backgroundColor = UIColor(rgb: 0xFB6060)
        self.thumbDownIcon.tintColor = UIColor(rgb: 0xFFFFFF)
        // TODO: down-voting event
    }
    
    @IBAction func upVoteEvent(_ sender: Any) {
        self.thumbUpView.backgroundColor = UIColor(rgb: 0x41E08D)
        self.thumbUpIcon.tintColor = UIColor(rgb: 0xFFFFFF)
        // TODO: up-voting event
    }
    
    @IBAction func editEvent(_ sender: Any) {
        self.overViewStacked = editionView
        self.animateInWithOptionalEffect(view: editionView, effect: false)

    }
    
    // MARK: - Comment View
    
    @IBAction func submitComment(_ sender: Any) {
        // TODO: submitting comment
    }
    
    @IBAction func cancelComment(_ sender: Any) {
        // TODO: cancel comment
    }
    
    // MARK: - Edition View
    
    @IBAction func changeDescription(_ sender: Any) {
        self.ref.child(self.selectedTagId!).updateChildValues(["description": self.newDescriptionTextField.text!])
        self.fetchTag(MarkerHash: selectedTag!.hash)
        self.animateOutWithOptionalEffect(effect: false)
        
    }
    
    @IBAction func deleteEvent(_ sender: Any) {
        self.removeTag(MarkerHash: selectedTag!.hash)
        self.mapView.removeAnnotation(selectedTag!)
        self.animateOutWithOptionalEffect(effect: false)
        self.animateOutWithOptionalEffect(effect: true)
        
    }
    
    @IBAction func closeEdition(_ sender: Any) {
        self.animateOutWithOptionalEffect(effect: false)

    }
    
    // MARK: - Map Interactions
    
    func isPressable(activate: Bool) {
        let PressRecognizer = UITapGestureRecognizer(target: self, action: #selector(PressOnMap))
        
        if (activate == true) {
            for recognizer in mapView.gestureRecognizers! where recognizer is UITapGestureRecognizer {
                PressRecognizer.require(toFail: recognizer)
            }
            self.mapView.addGestureRecognizer(PressRecognizer)
            isInside = true
            
        } else {
            self.mapView.removeGestureRecognizer(PressRecognizer)
            isInside = false
            
        }
    }
    
    // MARK: - Getters
    
    func getCurrentTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        let dateInFormat = dateFormatter.string(from: NSDate() as Date)
        return (dateInFormat)
        
    }
    
    func getCurrentUser() -> String {
        let userId = Auth.auth().currentUser?.uid
        return (userId ?? "Cannot get User")
        
    }
    
    func getUserNameById(userId: String) {
        let trace = Performance.startTrace(name: "getUserName")
        let userRef = Database.database().reference().child("users")
        
        userRef.child(userId).observeSingleEvent(of: .value) { (snapshot) in
            guard let data = snapshot.value as? NSDictionary else {
                trace?.stop()
                return
                
            }
            guard let userNameFromData = data["name"] as? String else {
                trace?.stop()
                return
                
            }
            self.userLabel.text = "Dropped by: " + userNameFromData + "."
            trace?.stop()
            
        }
    }
    
    func getDateFromString(time: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        dateFormatter.locale = Locale(identifier: "fr_GP")
        let date = dateFormatter.date(from:time)!
        return date
        
    }
    
    func getPastTime(for date : Date) -> String {
        
        var secondsAgo = Int(Date().timeIntervalSince(date))
        if secondsAgo < 0 {
            secondsAgo = secondsAgo * (-1)
            
        }
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        
        if secondsAgo < minute  {
            if secondsAgo < 2 {
                return "Just now."
                
            } else {
                return "\(secondsAgo) seconds ago."
                
            }
        } else if secondsAgo < hour {
            let min = secondsAgo/minute
            if min == 1{
                return "\(min) minutes ago."
                
            } else {
                return "\(min) minutes ago."
                
            }
        } else if secondsAgo < day {
            let hr = secondsAgo/hour
            if hr == 1{
                return "\(hr) hour ago."
                
            } else {
                return "\(hr) hours ago."
                
            }
        } else if secondsAgo < week {
            let day = secondsAgo/day
            if day == 1{
                return "\(day) day ago."
                
            } else {
                return "\(day) days ago."
                
            }
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd, hh:mm a"
            formatter.locale = Locale(identifier: "fr_GP")
            let strDate: String = formatter.string(from: date)
            return strDate
            
        }
    }
    
    // MARK: - Online Tag
    
    @discardableResult func putTag(mapView: MGLMapView, Tag: Tag) -> Int {
        
        let marker = MGLPointAnnotation()
        
        switch Tag.id {
        case 0:
            marker.coordinate.latitude = Tag.latitude!
            marker.coordinate.longitude = Tag.longitude!
            marker.title = "Jellyfishs"
            mapView.addAnnotation(marker)
            self.isPressable(activate: false)
        case 1:
            marker.coordinate.latitude = Tag.latitude!
            marker.coordinate.longitude = Tag.longitude!
            marker.title = "Divers"
            mapView.addAnnotation(marker)
            self.isPressable(activate: false)
        case 2:
            marker.coordinate.latitude = Tag.latitude!
            marker.coordinate.longitude = Tag.longitude!
            marker.title = "Waste"
            mapView.addAnnotation(marker)
            self.isPressable(activate: false)
        case 3:
            marker.coordinate.latitude = Tag.latitude!
            marker.coordinate.longitude = Tag.longitude!
            marker.title = "Warning"
            mapView.addAnnotation(marker)
            self.isPressable(activate: false)
        case 4:
            marker.coordinate.latitude = Tag.latitude!
            marker.coordinate.longitude = Tag.longitude!
            marker.title = "Dolphins"
            mapView.addAnnotation(marker)
            self.isPressable(activate: false)
        case 5:
            marker.coordinate.latitude = Tag.latitude!
            marker.coordinate.longitude = Tag.longitude!
            marker.title = "Destination"
            mapView.addAnnotation(marker)
            self.isPressable(activate: false)
        default:
            print("Error in func putTag")
            
        }
        return marker.hash
    }
    
    func putTagsinArray(markerHash: Int, FirebaseID: String) {
        self.Tags_ids.append(FirebaseID)
        self.Tags_hashs.append(markerHash)
        
    }
    
    func getTagsFromServer(mapView: MGLMapView) {
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                for tag in snapshot.children.allObjects as! [DataSnapshot] {
                    let data = tag.value as? NSDictionary
                    let description  = data?["description"] as? String
                    let id  = data?["groupId"] as? Int
                    let x = data?["latitude"] as? Double
                    let y = data?["longitude"] as? Double
                    let time = data?["time"] as? String
                    let user = data?["user"] as? String
                    var markerHash: Int
                    markerHash = self.putTag(mapView: mapView, Tag: Tag(description: description, id: id, latitude: x, longitude: y, time: time, user: user))
                    self.putTagsinArray(markerHash: markerHash, FirebaseID: tag.key)
                    
                }
            }
        }) { (error) in
            print(error.localizedDescription)
            
        }
    }
    
    func SyncData() {
        // related to firebase's real time database
        ref.observeSingleEvent(of: .childAdded) { (snapshot) in
            self.Tag_properties.description = snapshot.childSnapshot(forPath:"description").value as? String
            self.Tag_properties.id = snapshot.childSnapshot(forPath:"groupId").value as? Int
            self.Tag_properties.latitude = snapshot.childSnapshot(forPath:"latitude").value as? Double
            self.Tag_properties.longitude = snapshot.childSnapshot(forPath:"longitude").value as? Double
            _ = self.putTag(mapView: self.mapView, Tag: self.Tag_properties)
            
        }
        ref.observeSingleEvent(of: .childRemoved) { (snapshot) in
            let Tag_id = snapshot.key
            
            var count = 0
            while (self.Tags_ids[count] != Tag_id) {
                count = count + 1
            
            }
            let allAnnotations = self.mapView.annotations
            for eachAnnot in allAnnotations! {
                if eachAnnot.hash == self.Tags_hashs[count] {
                    print("MATCH")
                    self.mapView.removeAnnotation(eachAnnot)
                    self.removeTag(MarkerHash: self.Tags_hashs[count])
                
                }
            }
        }
    }
    
    // MARK: - Tag's Interactions
    
    func fetchTag(MarkerHash: Int) {
        var count = 0
        let hasDoneWork = false
        
        while (Tags_hashs[count] != MarkerHash) {
            count = count + 1
            
        }
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                for tag in snapshot.children.allObjects as! [DataSnapshot] {
                    
                    if (self.Tags_ids[count] == tag.key && hasDoneWork == false) {
                        let data = tag.value as? NSDictionary
                        let id  = data?["groupId"] as? Int
                        let description = data?["description"] as? String
                        let time = data?["time"] as? String
                        let user = data?["user"] as? String
                        
                        if description!.isEmpty == false {
                            self.newDescriptionTextField.text = description
                            
                        }
                    
                        self.timeLabel.text = self.getPastTime(for: self.getDateFromString(time: time!))
                        self.selectedTagId = tag.key
                        self.selectedTagUserId = user
                        self.descriptionLabel.text = description
                        
                        if user != Auth.auth().currentUser?.uid {
                            self.editButton.isEnabled = false
                            self.editIcon.isHidden = true
                            self.getUserNameById(userId: user!)
                            
                        } else {
                            self.userLabel.text = "You have dropped this event."
                            self.editButton.isEnabled = true
                            self.editIcon.isHidden = false
                            
                        }
                        
                        switch id {
                        case 0:
                            self.eventImage.image = UIImage(named: "jellyfishs")
                            self.eventLabel.text = "Jellyfish"
                            if description!.isEmpty {
                                self.descriptionLabel.text = "Jellyfish have been spotted at this location."
                            }
                        case 1:
                            self.eventImage.image = UIImage(named: "divers")
                            self.eventLabel.text = "Divers"
                            if description!.isEmpty {
                                self.descriptionLabel.text = "There are probably divers working here."
                            }
                        case 2:
                            self.eventImage.image = UIImage(named: "waste")
                            self.eventLabel.text = "Waste"
                            if description!.isEmpty {
                                self.descriptionLabel.text = "The water looks polluted here."
                            }
                        case 3:
                            self.eventImage.image = UIImage(named: "warning_black")
                            self.eventLabel.text = "SOS"
                            if description!.isEmpty {
                                self.descriptionLabel.text = "Someone needs help or there is a danger."
                            }
                        case 4:
                            self.eventImage.image = UIImage(named: "dolphins")
                            self.eventLabel.text = "Dolphins"
                            if description!.isEmpty {
                                self.descriptionLabel.text = "Dolphins have been spotted in the vicinity."
                            }
                        case 5:
                            self.eventImage.image = UIImage(named: "destination")
                            self.eventLabel.text = "Destination"
                            if description!.isEmpty {
                                self.descriptionLabel.text = "Someone is going there."
                            }
                        default:
                            print("Error deprecated tag.")
                            
                        }
                    }
                }
            }
        }) { (error) in
            print("Error: ", error.localizedDescription)
            
        }
    }
    
    func saveTags(Tag: Tag) -> String {
        
        print("SAVE TAGS DEBUT")
        
        let key = self.ref.childByAutoId().key
        let TagFirebase: [String: Any] = [
            "groupId": Tag.id as Any,
            "description": Tag.description as Any,
            "latitude": Tag.latitude as Any,
            "longitude": Tag.longitude as Any,
            "time": Tag.time as Any,
            "user": Tag.user as Any
        ]
        
        self.ref.child(key!).setValue(TagFirebase)
        return key!
        
    }
    
    func removeTag(MarkerHash: Int) {
        var count = 0
        
        while (Tags_hashs[count] != MarkerHash) {
            count = count + 1
        
        }
        
        self.ref.child(self.selectedTagId!).removeValue { (error, ref) in
            if error != nil {
                print("Failed to delete tag: ", error!)
                return
                
            }
            self.Tags_hashs.remove(at: count)
            self.Tags_ids.remove(at: count)
            
        }
    }
    
    // MARK: - Annotation
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
        
    }
    
    func mapView(_ mapView: MGLMapView, rightCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
        return UIButton(type: .contactAdd)
        
    }
    
    func mapView(_ mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
        // hide the callout view.
        mapView.deselectAnnotation(annotation, animated: false)
        
        self.viewStacked = descriptionView
        animateInWithOptionalEffect(view: descriptionView, effect: true)
        
        self.selectedTag = annotation
        fetchTag(MarkerHash: annotation.hash)
        
    }
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        if annotation is MGLUserLocation && mapView.userLocation != nil {
            return CustomUserLocationAnnotationView()
            
        }
        return nil
    }
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        
        var marker = MGLAnnotationImage()
        
        if annotation.title == "Dolphins" {
            var image = UIImage(named: "pin_dolphins")!
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
            marker = MGLAnnotationImage(image: image, reuseIdentifier: "Dolphins")
            
        } else if annotation.title == "Jellyfishs" {
            var image = UIImage(named: "pin_jellyfishs")!
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
            marker = MGLAnnotationImage(image: image, reuseIdentifier: "Jellyfishs")
            
        } else if annotation.title == "Divers" {
            var image = UIImage(named: "pin_divers")!
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
            marker = MGLAnnotationImage(image: image, reuseIdentifier: "Divers")
            
        } else if annotation.title == "Destination" {
            var image = UIImage(named: "pin_destination")!
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
            marker = MGLAnnotationImage(image: image, reuseIdentifier: "Destination")
            
        } else if annotation.title == "Warning" {
            var image = UIImage(named: "pin_warning")!
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
            marker = MGLAnnotationImage(image: image, reuseIdentifier: "Warning")
            
        } else {
            var image = UIImage(named: "pin_waste")!
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
            marker = MGLAnnotationImage(image: image, reuseIdentifier: "Waste")
            
        }
        return marker
    
    }
    
    @objc func PressOnMap(_ recognizer: UITapGestureRecognizer) {

        if (isInside == true) {
            let PressScreenCoordinates = recognizer.location(in: mapView)
            let PressMapCoordinates = mapView.convert(PressScreenCoordinates, toCoordinateFrom: mapView)
            Tag_properties.latitude = PressMapCoordinates.latitude
            Tag_properties.longitude = PressMapCoordinates.longitude
            let point = mapView.convert(PressMapCoordinates, toPointTo: mapView)
            let features = mapView.visibleFeatures(at: point, styleLayerIdentifiers: ["water"])
            if (features.description != "[]"){
                let ac = UIAlertController(title: "Add description (optional)", message: nil, preferredStyle: .alert)
                ac.addTextField()
                
                let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned ac] _ in
                    var FirebaseId: String
                    var markerHash: Int
                    self.Tag_properties.description = ac.textFields![0].text!
                    FirebaseId = self.saveTags(Tag: self.Tag_properties)
                    markerHash = self.putTag(mapView: self.mapView, Tag: self.Tag_properties)
                    self.putTagsinArray(markerHash: markerHash, FirebaseID: FirebaseId)
                    
                }
                ac.addAction(submitAction)
                present(ac, animated: true)
            
            } else {
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 50))
                label.center = CGPoint(x: mapView.center.x, y: 100)
                label.textColor = UIColor(rgb: 0x57A1FF)
                label.font = UIFont.boldSystemFont(ofSize: 25.0)
                label.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.7)
                label.clipsToBounds = true
                label.cornerRadius = 27.5
                label.textAlignment = .center
                label.text = "Can't drop markers on earth"
                self.view.addSubview(label)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    label.isHidden = true
                
                }
            }
        }
    }
}

// MARK: - Custom Class

class CustomUserLocationAnnotationView: MGLUserLocationAnnotationView {
    let size: CGFloat = 48
    var dot: CALayer!
    var arrow: CAShapeLayer!
    
    // -update is a method inherited from MGLUserLocationAnnotationView. It updates the appearance of the user location annotation when needed. This can be called many times a second, so be careful to keep it lightweight.
    override func update() {
        if frame.isNull {
            frame = CGRect(x: 0, y: 0, width: size, height: size)
            return setNeedsLayout()
            
        }
        
        // check whether we have the user’s location yet.
        if CLLocationCoordinate2DIsValid(userLocation!.coordinate) {
            setupLayers()
            updateHeading()
            
        }
    }
    
    private func updateHeading() {
        if let heading = userLocation!.heading?.trueHeading {
            arrow.isHidden = false
            
            let rotation: CGFloat = -MGLRadiansFromDegrees(mapView!.direction - heading)
            
            if abs(rotation) > 0.01 {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                arrow.setAffineTransform(CGAffineTransform.identity.rotated(by: rotation))
                CATransaction.commit()
                
            }
        } else {
            arrow.isHidden = true
            
        }
    }
    
    private func setupLayers() {
        // This dot forms the base of the annotation.
        if dot == nil {
            dot = CALayer()
            dot.bounds = CGRect(x: 0, y: 0, width: size, height: size)
            // Use CALayer’s corner radius to turn this layer into a circle.
            dot.cornerRadius = size / 2
            dot.backgroundColor = super.tintColor.cgColor
            dot.borderWidth = 4
            dot.borderColor = UIColor.white.cgColor
            layer.addSublayer(dot)
            
        }
        
        // This arrow overlays the dot and is rotated with the user’s heading.
        if arrow == nil {
            arrow = CAShapeLayer()
            arrow.path = arrowPath()
            arrow.frame = CGRect(x: 0, y: 0, width: size / 2, height: size / 2)
            arrow.position = CGPoint(x: dot.frame.midX, y: dot.frame.midY)
            arrow.fillColor = dot.borderColor
            layer.addSublayer(arrow)
            
        }
    }
    
    // Calculate the vector path for an arrow, for use in a shape layer.
    private func arrowPath() -> CGPath {
        let max: CGFloat = size / 2
        let pad: CGFloat = 3
        
        let top =    CGPoint(x: max * 0.5, y: 0)
        let left =   CGPoint(x: 0 + pad,   y: max - pad)
        let right =  CGPoint(x: max - pad, y: max - pad)
        let center = CGPoint(x: max * 0.5, y: max * 0.6)
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: top)
        bezierPath.addLine(to: left)
        bezierPath.addLine(to: center)
        bezierPath.addLine(to: right)
        bezierPath.addLine(to: top)
        bezierPath.close()
        
        return bezierPath.cgPath
        
    }
}
