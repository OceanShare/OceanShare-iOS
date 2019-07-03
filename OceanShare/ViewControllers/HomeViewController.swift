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
    var x_tag = 0.0
    var y_tag = 0.0
    var id_tag = 0
    var description_tag = "."
    var selectedTag: MGLAnnotation?
    var selectedTagId: String?
    
    // map properties
    var goinside = true
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
    @IBOutlet weak var thumbDownView: DesignableView!
    @IBOutlet weak var thumbDownIcon: UIImageView!
    @IBOutlet weak var thumbUpView: DesignableView!
    @IBOutlet weak var thumbUpIcon: UIImageView!
    @IBOutlet weak var editIcon: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var closeDescriptionIcon: UIImageView!
    
    // edition view
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
        
        // icon setup
        self.setupCustomIcons()
        
        // add the layers in the right order
        view.addSubview(mapView)
        view.addSubview(buttonMenu)
        view.addSubview(visualEffectView)
        
    }
    
    func setupCustomIcons() {
        // icon view
        self.closeIcon.image = self.closeIcon.image!.withRenderingMode(.alwaysTemplate)
        self.closeIcon.tintColor = UIColor(rgb: 0xFFFFFF)
        
        // description view
        self.editIcon.image = self.editIcon.image!.withRenderingMode(.alwaysTemplate)
        self.editIcon.tintColor = UIColor(rgb: 0xC5C7D2)
        self.closeDescriptionIcon.image = self.closeDescriptionIcon.image!.withRenderingMode(.alwaysTemplate)
        self.closeDescriptionIcon.tintColor = UIColor(rgb: 0xFFFFFF)
        self.thumbUpIcon.image = self.thumbUpIcon.image!.withRenderingMode(.alwaysTemplate)
        self.thumbUpIcon.tintColor = UIColor(rgb: 0x606060)
        self.thumbDownIcon.image = self.thumbDownIcon.image!.withRenderingMode(.alwaysTemplate)
        self.thumbDownIcon.tintColor = UIColor(rgb: 0x606060)
        
    }
    
    // MARK: - Animations
    
    func animateIn(view: UIView) {
        visualEffectView.isHidden = false
        self.view.addSubview(view)
        view.center = self.view.center
        
        view.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        view.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            self.visualEffectView.effect = self.effect
            view.alpha = 1
            view.transform = CGAffineTransform.identity
            self.visualEffectView.alpha = 0.8
            
        }
    }
    
    func animateInWithoutBlur(view: UIView) {
        self.view.addSubview(view)
        view.center = self.view.center
        
        view.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        view.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            view.alpha = 1
            view.transform = CGAffineTransform.identity
            
        }
    }
    
    func animateOut() {
        UIView.animate(withDuration: 0.3, animations: {
            self.viewStacked!.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.viewStacked!.alpha = 0
            self.visualEffectView.effect = nil
            
        }) { (success:Bool) in
            self.viewStacked!.removeFromSuperview()
            self.visualEffectView.isHidden = true
            
        }
    }
    
    func animateOutWithoutBlur() {
        UIView.animate(withDuration: 0.3, animations: {
            self.overViewStacked!.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.overViewStacked!.alpha = 0
            
        }) { (success:Bool) in
            self.overViewStacked!.removeFromSuperview()
            
        }
    }
    
    // MARK: - Menu Icon View
    
    @IBAction func closeMenu(_ sender: Any) {
        animateOut()
        
    }
    
    @IBAction func openMenu(_ sender: Any) {
        self.viewStacked = iconView
        animateIn(view: iconView)
        
    }
    
    @IBAction func medusaActivate(_ sender: Any) {
        Tag_properties.id = 0
        Tag_properties.description = "Medusa"
        Tag_properties.time = getCurrentTime()
        Tag_properties.user = getCurrentUser()
        self.Activate()
        animateOut()
        
    }
    
    @IBAction func diverActivate(_ sender: Any) {
        Tag_properties.id = 1
        Tag_properties.description = "Diver"
        Tag_properties.time = getCurrentTime()
        Tag_properties.user = getCurrentUser()
        self.Activate()
        animateOut()
        
    }
    
    @IBAction func wasteActivate(_ sender: Any) {
        Tag_properties.id = 2
        Tag_properties.description = "Waste"
        Tag_properties.time = getCurrentTime()
        Tag_properties.user = getCurrentUser()
        self.Activate()
        animateOut()
        
    }
    
    @IBAction func warningActivate(_ sender: Any) {
        Tag_properties.id = 3
        Tag_properties.description = "SOS"
        Tag_properties.time = getCurrentTime()
        Tag_properties.user = getCurrentUser()
        self.Activate()
        animateOut()
        
    }
    
    @IBAction func dolphinActivate(_ sender: Any) {
        Tag_properties.id = 4
        Tag_properties.description = "Dolphin"
        Tag_properties.time = getCurrentTime()
        Tag_properties.user = getCurrentUser()
        self.Activate()
        animateOut()
        
    }
    
    @IBAction func destinationActivate(_ sender: Any) {
        Tag_properties.id = 5
        Tag_properties.description = "Position"
        Tag_properties.time = getCurrentTime()
        Tag_properties.user = getCurrentUser()
        self.Activate()
        animateOut()
        
    }
    
    @IBAction func weatherActivate(_ sender: Any) {
        // TODO: add the weather event
        self.Activate()
        animateOut()
        
    }
    
    // MARK: - Description View
    
    @IBAction func closeDescription(_ sender: Any) {
        animateOut()
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
        animateInWithoutBlur(view: editionView)
        // TODO: editing event
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
        /*let Change = UIAlertAction(title: "Change Description", style: .default) { [unowned ac] _ in
         self.Tag_properties.description = ac.textFields![0].text!
         self.ChangeTag(MarkerHash: annotation.hash)
         mapView.removeAnnotation(annotation)*/
 
    }
    
    @IBAction func deleteEvent(_ sender: Any) {
        removeTag(MarkerHash: selectedTag!.hash)
        mapView.removeAnnotation(selectedTag!)
        animateOutWithoutBlur()
        animateOut()
        
    }
    
    @IBAction func closeEdition(_ sender: Any) {
        animateOutWithoutBlur()
    }
    
    // MARK: - Map Interactions
    
    func Activate() {
        let PressRecognizer = UITapGestureRecognizer(target: self, action: #selector(PressOnMap))
        
        self.mapView.addGestureRecognizer(PressRecognizer)
        print("Activate")
        isInside = true
        
        for recognizer in mapView.gestureRecognizers ?? [] {
            //   print("Active")
            //   print(recognizer)
            
        }
    }
    
    func Unactivate() {
        let PressRecognizer = UITapGestureRecognizer(target: self, action: #selector(PressOnMap))
        
        self.mapView.removeGestureRecognizer(PressRecognizer)
        print("Unactivate")
        isInside = false
        
        for recognizer in mapView.gestureRecognizers ?? [] {
            //      print("Unactive")
            //     print(recognizer)
            
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
    
    // MARK: - Online Tag
    
    func putTag(mapView: MGLMapView, Tag: Tag) -> Int {
        
        let marker = MGLPointAnnotation()
        
        switch Tag.id {
        case 0:
            marker.coordinate.latitude = Tag.latitude!
            marker.coordinate.longitude = Tag.longitude!
            marker.title = "Medusa"
            marker.subtitle = Tag.description
            mapView.addAnnotation(marker)
            Unactivate()
        case 1:
            marker.coordinate.latitude = Tag.latitude!
            marker.coordinate.longitude = Tag.longitude!
            marker.title = "Diver"
            marker.subtitle = Tag.description
            mapView.addAnnotation(marker)
            Unactivate()
        case 2:
            marker.coordinate.latitude = Tag.latitude!
            marker.coordinate.longitude = Tag.longitude!
            marker.title = "Waste"
            marker.subtitle = Tag.description
            mapView.addAnnotation(marker)
            Unactivate()
        case 3:
            marker.coordinate.latitude = Tag.latitude!
            marker.coordinate.longitude = Tag.longitude!
            marker.title = "SOS"
            marker.subtitle = Tag.description
            mapView.addAnnotation(marker)
            Unactivate()
        case 4:
            marker.coordinate.latitude = Tag.latitude!
            marker.coordinate.longitude = Tag.longitude!
            marker.title = "Dolphin"
            marker.subtitle = Tag.description
            mapView.addAnnotation(marker)
            Unactivate()
        case 5:
            marker.coordinate.latitude = Tag.latitude!
            marker.coordinate.longitude = Tag.longitude!
            marker.title = "Position"
            marker.subtitle = Tag.description
            mapView.addAnnotation(marker)
            Unactivate()
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
        // THIS IS FOR GETTING DATA WHEN DATA CHANGE IN FIREBASE
        
        ref.observeSingleEvent(of: .childAdded) { (snapshot) in
            print("CHILD_ADDED")
            
            for tag in snapshot.children.allObjects as! [DataSnapshot] {
                
                print(tag)
                // getting values
                /*      let data = tag.value as? NSDictionary
                 let description  = data?["description"] as? String
                 let id  = data?["id"] as? String
                 let x = data?["x"] as? Double
                 let y = data?["y"] as? Double
                 var markerHash: Int
                 markerHash = self.putTagfromServer(mapView: mapView, Tag: Tag(id: id, description: description, x: x, y: y))
                 print("Puttaginarray SHOWTAG")
                 self.putTagsinArray(markerHash: markerHash, FirebaseID: tag.key)*/
            
            }
        }
        ref.observeSingleEvent(of: .childRemoved) { (snapshot) in
            print("CHILD_REMOVED")
            
            for tag in snapshot.children.allObjects as! [DataSnapshot] {
                
                let data = snapshot.value as? NSDictionary
                //  print(tag)
                // getting values
                /*      let data = tag.value as? NSDictionary
                 let description  = data?["description"] as? String
                 let id  = data?["id"] as? String
                 let x = data?["x"] as? Double
                 let y = data?["y"] as? Double
                 var markerHash: Int
                 markerHash = self.putTagfromServer(mapView: mapView, Tag: Tag(id: id, description: description, x: x, y: y))
                 print("Puttaginarray SHOWTAG")
                 self.putTagsinArray(markerHash: markerHash, FirebaseID: tag.key)*/
            
            }
        }
    }
    
    // MARK: - Tag's Interactions
    
    func fetchTag(MarkerHash: Int) {
        var count = 0
        let hasDoneWork = false
        print(MarkerHash)
        print(Tags_hashs)
        
        while (Tags_hashs[count] != MarkerHash) {
            count = count + 1
            
        }
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            print("ChangeTag Childrencount = ", snapshot.childrenCount)
            if snapshot.childrenCount > 0 {
                for tag in snapshot.children.allObjects as! [DataSnapshot] {
                    
                    if (self.Tags_ids[count] == tag.key && hasDoneWork == false) {
                        let data = tag.value as? NSDictionary
                        let id  = data?["groupId"] as? Int
                        let description = data?["description"] as? String
                        let time = data?["time"] as? String
                        let user = data?["user"] as? String
                        
                        self.selectedTagId = tag.key
                        self.descriptionLabel.text = description
                        self.timeLabel.text = time! + " minutes ago"
                        
                        if user != Auth.auth().currentUser?.uid {
                            self.editButton.isEnabled = false
                            
                        } else {
                            self.editButton.isEnabled = true
                            
                        }
                        
                        switch id {
                        case 0:
                            self.eventImage.image = UIImage(named: "meduse")
                            self.eventLabel.text = "Jellyfish"
                            if description!.isEmpty {
                                self.descriptionLabel.text = "Jellyfish have been spotted at this location."
                            }
                        case 1:
                            self.eventImage.image = UIImage(named: "plongeur")
                            self.eventLabel.text = "Divers"
                            if description!.isEmpty {
                                self.descriptionLabel.text = "There are probably divers working here."
                            }
                        case 2:
                            self.eventImage.image = UIImage(named: "wasteP")
                            self.eventLabel.text = "Waste"
                            if description!.isEmpty {
                                self.descriptionLabel.text = "The water looks polluted here."
                            }
                        case 3:
                            self.eventImage.image = UIImage(named: "warnongBW")
                            self.eventLabel.text = "SOS"
                            if description!.isEmpty {
                                self.descriptionLabel.text = "Someone needs help or there is a danger."
                            }
                        case 4:
                            self.eventImage.image = UIImage(named: "dauphin")
                            self.eventLabel.text = "Dolphins"
                            if description!.isEmpty {
                                self.descriptionLabel.text = "Dolphins have been spotted in the vicinity."
                            }
                        case 5:
                            self.eventImage.image = UIImage(named: "Position")
                            self.eventLabel.text = "Destination"
                            if description!.isEmpty {
                                self.descriptionLabel.text = "Someone is going there."
                            }
                        default:
                            print("Error in func fetchTag")
                            
                        }
                    }
                }
            }
        }) { (error) in
            print("ERROR")
            print(error.localizedDescription)
            
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
    
    func ChangeTag(MarkerHash: Int) {
        var count = 0
        var hasDoneWork = false
        print(MarkerHash)
        print(Tags_hashs)

        while (Tags_hashs[count] != MarkerHash) {
            count = count + 1
            
        }
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            print("ChangeTag Childrencount = ", snapshot.childrenCount)
            if snapshot.childrenCount > 0 {
                for tag in snapshot.children.allObjects as! [DataSnapshot] {
                    
                    // getting valuess
                    if (self.Tags_ids[count] == tag.key && hasDoneWork == false) {
                        let data = tag.value as? NSDictionary
                        let id  = data?["groupId"] as? Int
                        let x = data?["latitude"] as? Double
                        let y = data?["longitude"] as? Double
                        let time = data?["time"] as? String
                        let user = data?["user"] as? String
                        var markerHash: Int
                        var FirebaseId: String
                        
                        self.removeTag(MarkerHash: self.Tags_hashs[count])
                        markerHash = self.putTag(mapView: self.mapView, Tag: Tag(description: self.Tag_properties.description, id: id, latitude: x, longitude: y, time: time, user: user))
                        FirebaseId = self.saveTags(Tag: Tag(description: self.Tag_properties.description, id: id, latitude: x, longitude: y, time: time, user: user))
                        self.putTagsinArray(markerHash: markerHash, FirebaseID: FirebaseId)
                        hasDoneWork = true
                        
                    }
                }
            }
        }) { (error) in
            print("ERROR")
            print(error.localizedDescription)
            
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
        animateIn(view: descriptionView)
        
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
        
        var test = MGLAnnotationImage()
        
        if annotation.title == "Dolphin" {
            var image = UIImage(named: "dauphin")!
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
            test = MGLAnnotationImage(image: image, reuseIdentifier: "Dauphin")
            
        } else if annotation.title == "Medusa" {
            var image = UIImage(named: "meduse")!
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
            test = MGLAnnotationImage(image: image, reuseIdentifier: "Meduse")
            
        } else if annotation.title == "Diver" {
            var image = UIImage(named: "plongeur")!
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
            test = MGLAnnotationImage(image: image, reuseIdentifier: "Plongeur")
            
        } else if annotation.title == "Position" {
            var image = UIImage(named: "Posititon")!
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
            test = MGLAnnotationImage(image: image, reuseIdentifier: "Posititon")
            
        } else if annotation.title == "SOS" {
            var image = UIImage(named: "warnongBW")!
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
            test = MGLAnnotationImage(image: image, reuseIdentifier: "Warning")
            
        } else {
            var image = UIImage(named: "wasteP")!
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
            test = MGLAnnotationImage(image: image, reuseIdentifier: "Waste")
            
        }
        return test
    
    }
    
    @objc func PressOnMap(_ recognizer: UITapGestureRecognizer) {

        if (isInside == true) {
            let PressScreenCoordinates = recognizer.location(in: mapView)
            let PressMapCoordinates = mapView.convert(PressScreenCoordinates, toCoordinateFrom: mapView)
            Tag_properties.latitude = PressMapCoordinates.latitude
            Tag_properties.longitude = PressMapCoordinates.longitude
            // Activate()
            let point = mapView.convert(PressMapCoordinates, toPointTo: mapView)
            let features = mapView.visibleFeatures(at: point, styleLayerIdentifiers: ["water"])
            
            if (features.description != "[]") {
            
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
                print("NOT WATER")
            
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
