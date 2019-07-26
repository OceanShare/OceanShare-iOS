//
//  HomeViewController.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 28/12/2018.
//  Copyright © 2018 Joseph Pereniguez. All rights reserved.
//

import UIKit
import Mapbox
import MapKit
import SwiftyJSON
import Alamofire
import CoreLocation
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore
import FirebaseStorage
import FirebasePerformance


class HomeViewController: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate {

    // MARK: - Variables
    
    // firebase
    var ref: DatabaseReference!
    let storageRef = FirebaseStorage.Storage().reference()
    
    // view
    var effect: UIVisualEffect!
    var viewStacked: UIView?
    var overViewStacked: UIView?
    var cordinate: CLLocationCoordinate2D!
    let locationManager = CLLocationManager()
    
    // map properties
    var isInside = false
    var mapView: MGLMapView!
    
    // tag properties
    var tagProperties = Tag(description: "", id: 0, latitude: 0.0, longitude: 0.0, time: "", user: "", timestamp: "")
    var tagIds = [String]()
    var tagHashs = [Int]()
    
    // saved tag
    var selectedTag: MGLAnnotation?
    var selectedTagId: String?
    var selectedTagUserId: String?
    var selectedTagUserName: String?
    
    // globals
    var uvGlobal: String!
    let registry = Registry()
    let weather = Weather.self
    let appUser = AppUser.self
    
    // MARK: - Outlets
    
    // map view
    @IBOutlet weak var centerIcon: UIImageView!
    @IBOutlet weak var centerView: DesignableButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var oceanShareLogo: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var longitudeView: DesignableView!
    @IBOutlet weak var currentLongitudeLabel: UILabel!
    @IBOutlet weak var latitudeView: DesignableView!
    @IBOutlet weak var currentLatitudeLabel: UILabel!
    
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
    @IBOutlet weak var editionView: UIView!
    @IBOutlet weak var newDescriptionTextField: UITextField!
    
    // wheater icon view
    @IBOutlet weak var weatherIconView: UIView!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var airTemperatureLabel: UILabel!
    @IBOutlet weak var weatherLongitudeLabel: UILabel!
    @IBOutlet weak var weatherLatitudeLabel: UILabel!
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
    
    // MARK: - View's Managers
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference().child("markers")
        
        syncData()
        setupView()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupCompass()
        
    }
    
    // MARK: - Location Manager
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        currentLatitudeLabel.text = String(format:"%f", locValue.latitude)
        currentLongitudeLabel.text = String(format:"%f", locValue.longitude)
        
    }
    
    // MARK: - Setup
    
    func setupView() {
        // blur effect
        effect = visualEffectView.effect
        visualEffectView.effect = nil
        visualEffectView.isHidden = true
        // mapview setup
        mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.logoView.isHidden = true
        mapView.attributionButton.isHidden = true
        // enable heading tracking mode (arrow will appear)
        mapView.userTrackingMode = .followWithHeading
        // enable the permanent heading indicator which will appear when the tracking mode is not `.followWithHeading`.
        mapView.showsUserHeadingIndicator = true
        getTagsFromServer(mapView: self.mapView)
        // icon setup
        setupCustomIcons()
        // add the layers in the right order
        view.addSubview(mapView)
        view.addSubview(headerView)
        view.addSubview(longitudeView)
        view.addSubview(latitudeView)
        view.addSubview(centerView)
        view.addSubview(buttonMenu)
        view.addSubview(visualEffectView)
        // setup the location manager
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            
        }
    }
    
    func setupCustomIcons() {
        // map view
        centerIcon.image = centerIcon.image!.withRenderingMode(.alwaysTemplate)
        centerIcon.tintColor = registry.customWhite
        
        // icon view
        closeIcon.image = closeIcon.image!.withRenderingMode(.alwaysTemplate)
        closeIcon.tintColor = registry.customBlack
        
        // description view
        editIcon.image = editIcon.image!.withRenderingMode(.alwaysTemplate)
        editIcon.tintColor = registry.customGrey
        closeDescriptionIcon.image = closeDescriptionIcon.image!.withRenderingMode(.alwaysTemplate)
        closeDescriptionIcon.tintColor = registry.customBlack
        thumbUpIcon.image = thumbUpIcon.image!.withRenderingMode(.alwaysTemplate)
        thumbUpIcon.tintColor = registry.customDarkGrey
        thumbDownIcon.image = thumbDownIcon.image!.withRenderingMode(.alwaysTemplate)
        thumbDownIcon.tintColor = registry.customDarkGrey
        
    }
    
    func setupCompass() {
        var centerPoint = mapView.compassView.center
        centerPoint.y = 130
        mapView.compassView.center = centerPoint
        
    }
    
    // MARK: - Animations
    
    func PutMessageOnHeader(msg: String, color: UIColor) {
        oceanShareLogo.isHidden = true
        headerView.backgroundColor = color
        messageLabel.text = msg
        messageLabel.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.messageLabel.isHidden = true
            self.oceanShareLogo.isHidden = false
            self.headerView.backgroundColor = self.registry.customMilkyWhite
            
        }
    }
    
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
    
    // MARK: - Map View
    
    @IBAction func centerMapToUser(_ sender: Any) {
        mapView.setCenter(mapView.userLocation!.coordinate, animated: true)
        
    }
    
    @IBAction func openMenu(_ sender: Any) {
        viewStacked = iconView
        animateInWithOptionalEffect(view: iconView, effect: true)
        
    }
    
    // MARK: - Icon View
    
    @IBAction func closeMenu(_ sender: Any) {
        animateOutWithOptionalEffect(effect: true)
        
    }
    
    @IBAction func medusaActivate(_ sender: Any) {
        tagProperties.id = 0
        tagProperties.description = "Jellyfishs"
        tagProperties.time = weather.getCurrentTime()
        tagProperties.user = appUser.getCurrentUser()
        tagProperties.timestamp = ServerValue.timestamp()
        putIconOnMap(activate: true)
        animateOutWithOptionalEffect(effect: true)
        PutMessageOnHeader(msg: "Jellyfishs event selected.", color: registry.customGreen)
        
    }
    
    @IBAction func diverActivate(_ sender: Any) {
        tagProperties.id = 1
        tagProperties.description = "Divers"
        tagProperties.time = weather.getCurrentTime()
        tagProperties.user = appUser.getCurrentUser()
        tagProperties.timestamp = ServerValue.timestamp()
        putIconOnMap(activate: true)
        animateOutWithOptionalEffect(effect: true)
        PutMessageOnHeader(msg: "Divers event selected.", color: registry.customGreen)
        
    }
    
    @IBAction func wasteActivate(_ sender: Any) {
        tagProperties.id = 2
        tagProperties.description = "Waste"
        tagProperties.time = weather.getCurrentTime()
        tagProperties.user = appUser.getCurrentUser()
        tagProperties.timestamp = ServerValue.timestamp()
        putIconOnMap(activate: true)
        animateOutWithOptionalEffect(effect: true)
        PutMessageOnHeader(msg: "Waste event selected.", color: registry.customGreen)
        
    }
    
    @IBAction func warningActivate(_ sender: Any) {
        tagProperties.id = 3
        tagProperties.description = "Warning"
        tagProperties.time = weather.getCurrentTime()
        tagProperties.user = appUser.getCurrentUser()
        tagProperties.timestamp = ServerValue.timestamp()
        putIconOnMap(activate: true)
        animateOutWithOptionalEffect(effect: true)
        PutMessageOnHeader(msg: "Warning event selected.", color: registry.customGreen)

    }
    
    @IBAction func dolphinActivate(_ sender: Any) {
        tagProperties.id = 4
        tagProperties.description = "Dolphins"
        tagProperties.time = weather.getCurrentTime()
        tagProperties.user = appUser.getCurrentUser()
        tagProperties.timestamp = ServerValue.timestamp()
        putIconOnMap(activate: true)
        animateOutWithOptionalEffect(effect: true)
        PutMessageOnHeader(msg: "Dolphins event selected.", color: registry.customGreen)

    }
    
    @IBAction func destinationActivate(_ sender: Any) {
        tagProperties.id = 5
        tagProperties.description = "Destination"
        tagProperties.time = weather.getCurrentTime()
        tagProperties.user = appUser.getCurrentUser()
        tagProperties.timestamp = ServerValue.timestamp()
        putIconOnMap(activate: true)
        animateOutWithOptionalEffect(effect: true)
        PutMessageOnHeader(msg: "Destination event selected.", color: registry.customGreen)

    }
    
    @IBAction func weatherActivate(_ sender: Any) {
        animateOutWithOptionalEffect(effect: true)
        putWeatherOnMap(activate: true)
        PutMessageOnHeader(msg: "Weather information selected.", color: registry.customGreen)

    }
    
    // MARK: - Description View
    
    @IBAction func closeDescription(_ sender: Any) {
        animateOutWithOptionalEffect(effect: true)
    }
    
    @IBAction func downVoteEvent(_ sender: Any) {
        thumbDownView.backgroundColor = registry.customRed
        thumbDownIcon.tintColor = registry.customWhite
        // TODO: down-voting event
    }
    
    @IBAction func upVoteEvent(_ sender: Any) {
        thumbUpView.backgroundColor = registry.customFlashGreen
        thumbUpIcon.tintColor = registry.customWhite
        // TODO: up-voting event
    }
    
    @IBAction func editEvent(_ sender: Any) {
        overViewStacked = editionView
        animateInWithOptionalEffect(view: editionView, effect: false)

    }
    
    // MARK: - Comment View
    
    @IBAction func submitComment(_ sender: Any) {
        var firebaseId: String
        var markerHash: Int
        
        tagProperties.description = descriptionTextField.text
        firebaseId = saveTags(Tag: tagProperties)
        markerHash = putTag(mapView: mapView, Tag: tagProperties)
        putTagsinArray(MarkerHash: markerHash, FirebaseID: firebaseId)
        animateOutWithOptionalEffect(effect: true)
        descriptionTextField.text = ""
        PutMessageOnHeader(msg: "Your event has been dropped.", color: registry.customGreen)
        putIconOnMap(activate: false)
        
    }
    
    @IBAction func cancelComment(_ sender: Any) {
        animateOutWithOptionalEffect(effect: true)
        descriptionTextField.text = ""
        putIconOnMap(activate: false)
        
    }
    
    // MARK: - Edition View
    
    @IBAction func changeDescription(_ sender: Any) {
        ref.child(selectedTagId!).updateChildValues(["description": newDescriptionTextField.text!])
        fetchTag(MarkerHash: selectedTag!.hash)
        animateOutWithOptionalEffect(effect: false)
        
    }
    
    @IBAction func deleteEvent(_ sender: Any) {
        removeTag(MarkerHash: selectedTag!.hash)
        mapView.removeAnnotation(selectedTag!)
        animateOutWithOptionalEffect(effect: false)
        animateOutWithOptionalEffect(effect: true)
        PutMessageOnHeader(msg: "Event correctly deleted.", color: registry.customGreen)
        
    }
    
    @IBAction func closeEdition(_ sender: Any) {
        animateOutWithOptionalEffect(effect: false)

    }
    
    // MARK: - Description View
    
    func getUserNameById(userId: String) {
        let trace = Performance.startTrace(name: registry.trace1)
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
    
    // MARK: - Online Tags
    
    @discardableResult func putTag(mapView: MGLMapView, Tag: Tag) -> Int {
        
        let marker = MGLPointAnnotation()
        
        switch Tag.id {
        case 0:
            marker.coordinate.latitude = Tag.latitude!
            marker.coordinate.longitude = Tag.longitude!
            marker.title = "Jellyfishs"
            mapView.addAnnotation(marker)
        case 1:
            marker.coordinate.latitude = Tag.latitude!
            marker.coordinate.longitude = Tag.longitude!
            marker.title = "Divers"
            mapView.addAnnotation(marker)
        case 2:
            marker.coordinate.latitude = Tag.latitude!
            marker.coordinate.longitude = Tag.longitude!
            marker.title = "Waste"
            mapView.addAnnotation(marker)
        case 3:
            marker.coordinate.latitude = Tag.latitude!
            marker.coordinate.longitude = Tag.longitude!
            marker.title = "Warning"
            mapView.addAnnotation(marker)
        case 4:
            marker.coordinate.latitude = Tag.latitude!
            marker.coordinate.longitude = Tag.longitude!
            marker.title = "Dolphins"
            mapView.addAnnotation(marker)
        case 5:
            marker.coordinate.latitude = Tag.latitude!
            marker.coordinate.longitude = Tag.longitude!
            marker.title = "Destination"
            mapView.addAnnotation(marker)
        default:
            print("Error in func putTag")
            
        }
        return marker.hash
    }
    
    func putTagsinArray(MarkerHash: Int, FirebaseID: String) {
        tagIds.append(FirebaseID)
        tagHashs.append(MarkerHash)
        
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
                    let timestamp = data?["timestamp"] as? String
                    var markerHash: Int
                    markerHash = self.putTag(mapView: mapView, Tag: Tag(description: description, id: id, latitude: x, longitude: y, time: time, user: user, timestamp: timestamp))
                    self.putTagsinArray(MarkerHash: markerHash, FirebaseID: tag.key)
                    
                }
            }
        }) { (error) in
            print(error.localizedDescription)
            
        }
    }
    
    func syncData() {
        // related to firebase's real time database
        ref.observeSingleEvent(of: .childAdded) { (snapshot) in
            self.tagProperties.description = snapshot.childSnapshot(forPath:"description").value as? String
            self.tagProperties.id = snapshot.childSnapshot(forPath:"groupId").value as? Int
            self.tagProperties.latitude = snapshot.childSnapshot(forPath:"latitude").value as? Double
            self.tagProperties.longitude = snapshot.childSnapshot(forPath:"longitude").value as? Double
            _ = self.putTag(mapView: self.mapView, Tag: self.tagProperties)
            
        }
        ref.observeSingleEvent(of: .childRemoved) { (snapshot) in
            let Tag_id = snapshot.key
            
            var count = 0
            while (self.tagIds[count] != Tag_id) {
                count = count + 1
            
            }
            let allAnnotations = self.mapView.annotations
            for eachAnnot in allAnnotations! {
                if eachAnnot.hash == self.tagHashs[count] {
                    print("MATCH")
                    self.mapView.removeAnnotation(eachAnnot)
                    self.removeTag(MarkerHash: self.tagHashs[count])
                
                }
            }
        }
    }
    
    // MARK: - Tag's Interactions
    
    func fetchTag(MarkerHash: Int) {
        var count = 0
        let hasDoneWork = false
        
        while (tagHashs[count] != MarkerHash) {
            count = count + 1
            
        }
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                for tag in snapshot.children.allObjects as! [DataSnapshot] {
                    
                    if (self.tagIds[count] == tag.key && hasDoneWork == false) {
                        let data = tag.value as? NSDictionary
                        let id  = data?["groupId"] as? Int
                        let description = data?["description"] as? String
                        let time = data?["time"] as? String
                        let user = data?["user"] as? String
                        
                        if description!.isEmpty == false {
                            self.newDescriptionTextField.text = description
                            
                        }
                    
                        self.timeLabel.text = self.weather.getPastTime(for: self.weather.getDateFromString(time: time!))
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
                            self.eventLabel.text = "Warning"
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
            "user": Tag.user as Any,
            "timestamp": Tag.timestamp as Any
        ]
        
        self.ref.child(key!).setValue(TagFirebase)
        return key!
        
    }
    
    func removeTag(MarkerHash: Int) {
        var count = 0
        
        while (tagHashs[count] != MarkerHash) {
            count = count + 1
        
        }
        
        ref.child(selectedTagId!).removeValue { (error, ref) in
            if error != nil {
                print("Failed to delete tag: ", error!)
                return
                
            }
            self.tagHashs.remove(at: count)
            self.tagIds.remove(at: count)
            
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
        // description view popup animation
        viewStacked = descriptionView
        animateInWithOptionalEffect(view: descriptionView, effect: true)
        // fetch the selected tag
        selectedTag = annotation
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
    
    // MARK: - Gesture Recognizers
    
    func putIconOnMap(activate: Bool) {
        let pressRecognizer = UITapGestureRecognizer(target: self, action: #selector(PressOnMap))
        pressRecognizer.name = "pressRecognizer"
        
        for recognizer in mapView.gestureRecognizers! where recognizer is UITapGestureRecognizer {
            if recognizer.name == "pressRecognizerWithoutDisplay" {
                mapView.removeGestureRecognizer(recognizer)
                
            }
        }
        
        if (activate == true) {
            for recognizer in mapView.gestureRecognizers! where recognizer is UITapGestureRecognizer {
                pressRecognizer.require(toFail: recognizer)
            }
            self.mapView.addGestureRecognizer(pressRecognizer)
            self.isInside = true
            
        } else {
            self.mapView.removeGestureRecognizer(pressRecognizer)
            self.isInside = false
            
        }
    }
    
    @objc func PressOnMap(_ recognizer: UITapGestureRecognizer) {
        if (self.isInside == true) {
            let PressScreenCoordinates = recognizer.location(in: mapView)
            let PressMapCoordinates = mapView.convert(PressScreenCoordinates, toCoordinateFrom: mapView)
            tagProperties.latitude = PressMapCoordinates.latitude
            tagProperties.longitude = PressMapCoordinates.longitude
            
            let point = mapView.convert(PressMapCoordinates, toPointTo: mapView)
            let features = mapView.visibleFeatures(at: point, styleLayerIdentifiers: ["water"])
            if (features.description != "[]") {
                self.viewStacked = commentView
                self.animateInWithOptionalEffect(view: commentView, effect: true)
                
            } else {
                self.PutMessageOnHeader(msg: "Can't drop markers on earth.", color: self.registry.customRed)
                
            }
        }
    }
    
    func putWeatherOnMap(activate: Bool) {
        let pressRecognizerWithoutDisplay = UITapGestureRecognizer(target: self, action: #selector(PressOnMapWithoutDisplay))
        pressRecognizerWithoutDisplay.name = "pressRecognizerWithoutDisplay"
        
        for recognizer in mapView.gestureRecognizers! where recognizer is UITapGestureRecognizer {
            if recognizer.name == "pressRecognizer" {
                mapView.removeGestureRecognizer(recognizer)
                
            }
        }
        
        if (activate == true) {
            
            for recognizer in mapView.gestureRecognizers! where recognizer is UITapGestureRecognizer {
                pressRecognizerWithoutDisplay.require(toFail: recognizer)
            }
            self.mapView.addGestureRecognizer(pressRecognizerWithoutDisplay)
            self.isInside = true
            
        } else {
            self.mapView.removeGestureRecognizer(pressRecognizerWithoutDisplay)
            self.isInside = false
            
        }
    }

    @objc func PressOnMapWithoutDisplay(_ recognizer: UITapGestureRecognizer) {
        if (self.isInside == true) {
            let PressScreenCoordinates = recognizer.location(in: mapView)
            let PressMapCoordinates = mapView.convert(PressScreenCoordinates, toCoordinateFrom: mapView)
            let longitude = PressMapCoordinates.longitude
            let latitude = PressMapCoordinates.latitude
            self.getWeatherFromSelectedLocation(long: longitude, lat: latitude)
            
            let point = mapView.convert(PressMapCoordinates, toPointTo: mapView)
            let features = mapView.visibleFeatures(at: point, styleLayerIdentifiers: ["water"])
            if (features.description != "[]") {
                self.viewStacked = self.weatherIconView
                self.animateInWithOptionalEffect(view: weatherIconView, effect: true)
                self.putWeatherOnMap(activate: false)
                
            } else {
                self.PutMessageOnHeader(msg: "Can't get weather from earth.", color: self.registry.customRed)
                
            }
        }
    }
    
    // MARK: - Weather
    
    func getWeatherFromSelectedLocation(long: Double, lat: Double) {
        let param: Parameters = [
            "lat": String(lat),
            "lng": String(long)]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJVc2VySWQiOjF9.Vcp2grZ53t_OG3jwSXsRwfc_UUjboNgZarkAGiX0jgM" ]
        
        let trace = Performance.startTrace(name: registry.trace2)
        _ = AF.request("http://35.198.134.25:5000/api/weather",
                       method: .get,
                       parameters: param,
                       encoding: URLEncoding.default,
                       headers: headers).validate(statusCode: 200..<500).responseJSON(completionHandler: {response in
                        switch response.result {
                        case .success(let value):
                            let jsonObject = JSON(value)
                            self.transformData(rawData: jsonObject)
                        case .failure(let error):
                            print(error)
                        }})
        trace?.stop()
    }
    
    func transformData(rawData: JSON) {
        // get uv index
        if let uvData = rawData["uv"].string {
            let uvAsData = uvData.data(using: .utf8)!
            let uvAsJson = JSON(uvAsData)
            
            if let uvIndex = uvAsJson["value"].double {
                self.uvGlobal = self.weather.analyseUvIndex(uvIndex: uvIndex)
                
            } else {
                print(uvAsJson["value"].error!)
                
            }
        }
        // get weather
        if let data = rawData["weather"].string {
            let dataAsData = data.data(using: .utf8)!
            let dataAsJson = JSON(dataAsData)
            
            do {
                _ = try JSONSerialization.jsonObject(
                    with: dataAsData,
                    options: .mutableContainers) as! [String: AnyObject]
                
                let weather = Weather(weatherData: dataAsJson)
                self.didGetWeather(weather: weather)
            } catch let jsonError as NSError {
                self.didNotGetWeather(error: jsonError)
                
            }
        } else {
            print(rawData["weather"].error!)
            
        }
    }
    
    func didGetWeather(weather: Weather) {
        DispatchQueue.main.async {
            print("Value to check (weatherID -> weatherImage): ", weather.weatherID)
            self.weatherImage.image = self.weather.analyseDescription(weather: weather, registry: self.registry)
            
            self.airTemperatureLabel.text = "\(Int(round(weather.tempCelsius))) °C"
            self.weatherLabel.text = weather.weatherDescription
            
            self.weatherLongitudeLabel.text = String(format:"%f", weather.longitude)
            self.weatherLatitudeLabel.text = String(format:"%f", weather.latitude)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            formatter.locale = Locale(identifier: "fr_GP")
            let sunriseDate: String = formatter.string(from: weather.sunrise)
            self.sunriseLabel.text = sunriseDate
            let sunsetDate: String = formatter.string(from: weather.sunset)
            self.sunsetLabel.text = sunsetDate
            
            self.rainRiskLabel.text = "\(weather.cloudCover) %"
            self.waterTemperatureLabel.text = "-- °C"
            
            // TODO: check
            //self.windLabel.text = "\(round(100 * (weather.windSpeed * ( 60 * 60 ) / 1000)) / 100) km/h"
            self.windLabel.text = self.weather.analyseWindDirection(degrees: weather.windSpeed)
            self.humidityLabel.text = "\(weather.humidity) %"
            
            if weather.visibility != nil {
                self.visibilityLabel.text = "\(round(100 * (Double(weather.visibility! / 1000))) / 100) km"
            } else {
                self.visibilityLabel.text = "-- km"
            }
            if self.uvGlobal != nil {
                self.uvLabel.text = self.uvGlobal
                
            } else {
                self.uvLabel.text = "--"
                
            }
        }
    }
    
    func didNotGetWeather(error: NSError) {
        DispatchQueue.main.async {
            self.airTemperatureLabel.text = "Unknown"
            self.weatherLabel.text = "Unknown"
            self.sunriseLabel.text = "Unknown"
            self.sunsetLabel.text = "Unknown"
            self.rainRiskLabel.text = "Unknown"
            self.waterTemperatureLabel.text = "Unknown"
            self.windLabel.text = "Unknown"
            self.humidityLabel.text = "Unknown"
            self.visibilityLabel.text = "Unknown"
            self.uvLabel.text = "Unknown"
        }
        print("Error: \(error) in function didNotGetWeather (WeatherViewController.Swift).")
        
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
        
        let top = CGPoint(x: max * 0.5, y: 0)
        let left = CGPoint(x: 0 + pad, y: max - pad)
        let right = CGPoint(x: max - pad, y: max - pad)
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
