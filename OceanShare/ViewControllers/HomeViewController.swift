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
import Turf
import SwiftyJSON
import Alamofire
import CoreLocation
import FirebaseFunctions
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore
import FirebaseStorage
import FirebasePerformance


class HomeViewController: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate {

    // MARK: - Variables
    
    /* firebase */
    var ref: DatabaseReference!
    var userRef: DatabaseReference!
    let storageRef = Storage.storage().reference()
    
    /* view */
    var effect: UIVisualEffect!
    var viewStacked: UIView?
    var overViewStacked: UIView?
    var cordinate: CLLocationCoordinate2D!
    let locationManager = CLLocationManager()
    
    /* map properties */
    var isInside = false
    var mapView: MGLMapView!
    
    /* tag properties */
    var tagIds = [String]()
    var tagHashs = [Int]()
    var tagProperties = Tag(description: "",
                            id: 0, latitude: 0.0,
                            longitude: 0.0,
                            time: "",
                            user: "",
                            timestamp: "",
                            upvote: 0,
                            downvote: 0,
                            contributors: ["":0])
    
    /* saved tag */
    var selectedTag: MGLAnnotation!
    var selectedTagId: String?
    var selectedTagUserId: String?
    var selectedTagUserName: String?
    var isUserDeletingTag = false
    var isUserAddingTag = false
    
    /* globals */
    var uvGlobal: String!
    var droppedIconNumber: Int! = 0
    let registry = Registry()
    let weather = Weather.self
    let currentUser = AppUser.self

    // MARK: - Outlets
    
    /* map view */
    @IBOutlet weak var centerIcon: UIImageView!
    @IBOutlet weak var centerView: DesignableButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var oceanShareLogo: UIImageView!
    @IBOutlet weak var messageLabel: UITextView!
    @IBOutlet weak var longitudeView: DesignableView!
    @IBOutlet weak var longitudeIndicatorLabel: UILabel!
    @IBOutlet weak var currentLongitudeLabel: UILabel!
    @IBOutlet weak var latitudeView: DesignableView!
    @IBOutlet weak var latitudeIndicatorLabel: UILabel!
    @IBOutlet weak var currentLatitudeLabel: UILabel!
    @IBOutlet weak var mapItem: UITabBarItem!
    
    /* icon view */
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var iconViewEventTextView: UITextView!
    @IBOutlet weak var iconViewJellyfishs: UILabel!
    @IBOutlet weak var iconViewDivers: UILabel!
    @IBOutlet weak var iconViewWaste: UILabel!
    @IBOutlet weak var iconViewWarning: UILabel!
    @IBOutlet weak var iconViewDolphins: UILabel!
    @IBOutlet weak var iconViewDestination: UILabel!
    @IBOutlet weak var iconViewWeatherTextView: UITextView!
    @IBOutlet weak var iconViewWeather: UILabel!
    @IBOutlet weak var closeIcon: UIImageView!
    @IBOutlet weak var buttonMenu: DesignableButton!
    
    /* comment view */
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var commentViewDescription: UITextView!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var commentViewSubmit: DesignableButton!
    @IBOutlet weak var commentViewCancel: DesignableButton!
    
    /* description view */
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var ratedLabel: UITextView!
    @IBOutlet weak var ratingStackView: UIStackView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var thumbDownView: DesignableView!
    @IBOutlet weak var downVoteButton: UIButton!
    @IBOutlet weak var thumbDownIcon: UIImageView!
    @IBOutlet weak var thumbUpView: DesignableView!
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var thumbUpIcon: UIImageView!
    @IBOutlet weak var editButton: DesignableButton!
    @IBOutlet weak var closeDescriptionIcon: UIImageView!
    @IBOutlet weak var downvotedCounter: UILabel!
    @IBOutlet weak var upvotedCounter: UILabel!
    
    /* user description view */
    @IBOutlet weak var userDescriptionView: UIView!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var userAvatarName: UILabel!
    
    /* edition view */
    @IBOutlet weak var editionView: UIView!
    @IBOutlet weak var editionViewDescription: UITextView!
    @IBOutlet weak var newDescriptionTextField: UITextField!
    @IBOutlet weak var editionViewSave: DesignableButton!
    @IBOutlet weak var editionViewCancel: DesignableButton!
    @IBOutlet weak var editionViewDelete: DesignableButton!
    
    /* wheater icon view */
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
    
    /* visual effect */
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    // MARK: - View Manager
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference().child("markers")
        userRef = Database.database().reference().child("users")
        
        syncData()
        setupView()
        setupInfo()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupCompass()
        
    }
    
    // MARK: - Setup

    /*
     * Setup embeded views from home view controller.
     */
    func setupView() {
        /* blur effect */
        effect = visualEffectView.effect
        visualEffectView.effect = nil
        visualEffectView.isHidden = true
        /* mapview setup */
        mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.logoView.isHidden = true
        mapView.attributionButton.isHidden = true
        mapView.userTrackingMode = .followWithHeading
        mapView.showsUserHeadingIndicator = true
        getTagsFromServer(mapView: self.mapView)
        /* icon setup */
        setupCustomIcons()
        /* set localized labels */
        setupLocalizedStrings()
        /* add the layers in the right order */
        view.addSubview(mapView)
        view.addSubview(headerView)
        view.addSubview(longitudeView)
        view.addSubview(latitudeView)
        view.addSubview(centerView)
        view.addSubview(buttonMenu)
        view.addSubview(visualEffectView)
        
    }
    
    /*
     * Setup user's longitude and latitude from location manager.
     */
    func setupInfo() {
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            
        }
    }
    
    /*
     * Real time location manager.
     * Update user's lalitude and longitude.
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        currentLatitudeLabel.text = String(format:"%f", locValue.latitude)
        currentLongitudeLabel.text = String(format:"%f", locValue.longitude)
        
        let userLongitude: [String: Any] = ["longitude": String(format:"%f", locValue.longitude) as Any]
        let userLattitude: [String: Any] = ["latitude": String(format:"%f", locValue.latitude) as Any]
        let uid = Auth.auth().currentUser!.uid
        
        self.userRef.child("\(uid)/location").updateChildValues(userLongitude)
        self.userRef.child("\(uid)/location").updateChildValues(userLattitude)
    }
    
    /*
     * Setup labels.
     */
    func setupLocalizedStrings() {
        /* view */
        longitudeIndicatorLabel.text = NSLocalizedString("longitude", comment: "")
        latitudeIndicatorLabel.text = NSLocalizedString("latitude", comment: "")
        /* icon view */
        iconViewEventTextView.text = NSLocalizedString("iconViewEventTextView", comment: "")
        iconViewJellyfishs.text = NSLocalizedString("iconViewJellyfishs", comment: "")
        iconViewDivers.text = NSLocalizedString("iconViewDivers", comment: "")
        iconViewWaste.text = NSLocalizedString("iconViewWaste", comment: "")
        iconViewWarning.text = NSLocalizedString("iconViewWarning", comment: "")
        iconViewDolphins.text = NSLocalizedString("iconViewDolphins", comment: "")
        iconViewDestination.text = NSLocalizedString("iconViewDestination", comment: "")
        iconViewWeatherTextView.text = NSLocalizedString("iconViewWeatherTextView", comment: "")
        iconViewWeather.text = NSLocalizedString("iconViewWeather", comment: "")
        /* comment view */
        commentViewDescription.text = NSLocalizedString("commentViewDescription", comment: "")
        descriptionTextField.placeholder = NSLocalizedString("commentViewDescriptionTextField", comment: "")
        commentViewSubmit.setTitle(NSLocalizedString("commentViewSubmit", comment: ""), for: .normal)
        commentViewCancel.setTitle(NSLocalizedString("commentViewCancel", comment: ""), for: .normal)
        /* edition view */
        editionViewDescription.text = NSLocalizedString("editionViewDescription", comment: "")
        newDescriptionTextField.placeholder = NSLocalizedString("newDescriptionTextField", comment: "")
        editionViewSave.setTitle(NSLocalizedString("editionViewSave", comment: ""), for: .normal)
        editionViewCancel.setTitle(NSLocalizedString("editionViewCancel", comment: ""), for: .normal)
        editionViewDelete.setTitle(NSLocalizedString("editionViewDelete", comment: ""), for: .normal)
        /* description view */
        editButton.setTitle(NSLocalizedString("edit", comment: ""), for: .normal)
    }
    
    /*
     * Setup custom icons.
     */
    func setupCustomIcons() {
        /* map view */
        centerIcon.image = centerIcon.image!.withRenderingMode(.alwaysTemplate)
        centerIcon.tintColor = registry.customWhite
        /* icon view */
        closeIcon.image = closeIcon.image!.withRenderingMode(.alwaysTemplate)
        closeIcon.tintColor = registry.customBlack
        /* description view */
        closeDescriptionIcon.image = closeDescriptionIcon.image!.withRenderingMode(.alwaysTemplate)
        closeDescriptionIcon.tintColor = registry.customBlack
        thumbUpIcon.image = thumbUpIcon.image!.withRenderingMode(.alwaysTemplate)
        thumbUpIcon.tintColor = registry.customDarkGrey
        thumbDownIcon.image = thumbDownIcon.image!.withRenderingMode(.alwaysTemplate)
        thumbDownIcon.tintColor = registry.customDarkGrey
        
    }
    
    /*
     * Setup the compass from mapview.
     */
    func setupCompass() {
        var centerPoint = mapView.compassView.center
        centerPoint.y = 130
        mapView.compassView.center = centerPoint
        
    }
    
    // MARK: - Animations
    
    /*
     * Display a message on the header depending of interactions the user has with markers.
     * It takes the message to display and the alert type color as parameters.
     */
    func PutMessageOnHeader(msg: String, color: UIColor) {
        oceanShareLogo.isHidden = true
        headerView.backgroundColor = color
        messageLabel.text = msg
        messageLabel.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
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

        getDroppedIconByUser()
        
    }
    
    // MARK: - Icon View
    
    @IBAction func closeMenu(_ sender: Any) {
        animateOutWithOptionalEffect(effect: true)
        
    }
    
    @IBAction func medusaActivate(_ sender: Any) {
        eventActivator(eventId: 0, eventDescription: "Jellyfishs", eventMessage: self.registry.msgJellyfishs)
        
    }
    
    @IBAction func diverActivate(_ sender: Any) {
        eventActivator(eventId: 1, eventDescription: "Divers", eventMessage: self.registry.msgDivers)
        
    }
    
    @IBAction func wasteActivate(_ sender: Any) {
        eventActivator(eventId: 2, eventDescription: "Waste", eventMessage: self.registry.msgWaste)
        
    }
    
    @IBAction func warningActivate(_ sender: Any) {
        eventActivator(eventId: 3, eventDescription: "Warning", eventMessage: self.registry.msgWarning)

    }
    
    @IBAction func dolphinActivate(_ sender: Any) {
        eventActivator(eventId: 4, eventDescription: "Dolphins", eventMessage: self.registry.msgDolphins)
        
    }
    
    @IBAction func destinationActivate(_ sender: Any) {
        eventActivator(eventId: 5, eventDescription: "Destination", eventMessage: self.registry.msgDestination)
        
    }
    
    @IBAction func weatherActivate(_ sender: Any) {
        animateOutWithOptionalEffect(effect: true)
        putWeatherOnMap(activate: true)
        PutMessageOnHeader(msg: self.registry.msgWeather, color: registry.customGreen)

    }
    
    func eventActivator (eventId: Int, eventDescription: String, eventMessage: String) {
        if (droppedIconNumber! < 5) {
            tagProperties.id = eventId
            tagProperties.description = eventDescription
            tagProperties.time = weather.getCurrentTime()
            tagProperties.user = currentUser.getCurrentUser()
            tagProperties.timestamp = ServerValue.timestamp()
            tagProperties.upvote = 0
            tagProperties.downvote = 0
            tagProperties.contributors = [currentUser.getCurrentUser() : 0]
            putIconOnMap(activate: true)
            animateOutWithOptionalEffect(effect: true)
            PutMessageOnHeader(msg: eventMessage, color: registry.customGreen)
            
        } else {
            animateOutWithOptionalEffect(effect: true)
            self.PutMessageOnHeader(msg: self.registry.msgEventLimit, color: self.registry.customRed)
            
        }
    }
    
    // MARK: - User Description View
    
    /*
    * Close the user description view.
    */
    @IBAction func closeUserDescription(_ sender: Any) {
        animateOutWithOptionalEffect(effect: true)
    }
    
    func fetchUserDescription() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        userRef.child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot == snapshot {
                guard let data = snapshot.value as? NSDictionary else { return }
                guard let name = data["name"] as? String else { return }
            
                self.userAvatarName.text = name
            
            }
        })
    }
    
    // MARK: - Description View
    
    /*
     * Close the description view.
     */
    @IBAction func closeDescription(_ sender: Any) {
        animateOutWithOptionalEffect(effect: true)
        
    }
    
    /*
     * Open the edition view to modify the event.
     */
    @IBAction func editEvent(_ sender: Any) {
        overViewStacked = editionView
        animateInWithOptionalEffect(view: editionView, effect: false)
        
    }
    
    /*
     * Downvote an event and check if the event has 3 or more downvotes.
     * If it has, the function delete this event.
     */
    @IBAction func downVoteEvent(_ sender: Any) {
        thumbDownView.backgroundColor = registry.customRed
        thumbDownIcon.tintColor = registry.customWhite
        upVoteButton.isEnabled = false
        downVoteButton.isEnabled = false
        ratedLabel.text = NSLocalizedString("hasBeenDownvoted", comment: "")
        
        let uid = Auth.auth().currentUser!.uid
        let markerData: [String: Int] = [uid: 2]
        
        ref.child(selectedTagId!).child("contributors").updateChildValues(markerData)
        ref.child(selectedTagId!).observeSingleEvent(of: .value) { (snapshot) in
            guard let data = snapshot.value as? NSDictionary else { return }
            guard var downVoteAmount = data["downvote"] as? Int else { return }
            guard let upVoteAmount = data["upvote"] as? Int else { return }
            
            let updatedAmount = ["downvote" : downVoteAmount + 1]
            self.downvotedCounter.text = "\(downVoteAmount + 1)" // todo -> test
            downVoteAmount = downVoteAmount + 1
            self.ref.child(self.selectedTagId!).updateChildValues(updatedAmount)
            if ((downVoteAmount - upVoteAmount) >= 3) {
                let annotations = self.mapView.annotations!
                
                self.mapView.removeAnnotations(annotations)
                self.isUserDeletingTag = true
                self.removeTag()
                self.getDroppedIconByUser()
            }
        }
    }
    
    /*
     * Upvote an event.
     */
    @IBAction func upVoteEvent(_ sender: Any) {
        thumbUpView.backgroundColor = registry.customFlashGreen
        thumbUpIcon.tintColor = registry.customWhite
        upVoteButton.isEnabled = false
        downVoteButton.isEnabled = false
        ratedLabel.text = NSLocalizedString("hasBeenUpvoted", comment: "")
        
        let uid = Auth.auth().currentUser!.uid
        let markerData: [String: Int] = [uid: 1]
        
        ref.child(selectedTagId!).child("contributors").updateChildValues(markerData)
        ref.child(selectedTagId!).observeSingleEvent(of: .value) { (snapshot) in
            guard let data = snapshot.value as? NSDictionary else { return }
            guard let voteAmount = data["upvote"] as? Int else { return }
            let updatedAmount = ["upvote" : voteAmount + 1]
            self.upvotedCounter.text = "\(voteAmount + 1)"
            self.ref.child(self.selectedTagId!).updateChildValues(updatedAmount)
            
        }
    }
    
    // MARK: - Comment View
    
    @IBAction func submitComment(_ sender: Any) {
        var firebaseId: String
        var markerHash: Int
        isUserAddingTag = true
        
        tagProperties.description = descriptionTextField.text
        firebaseId = saveTags(Tag: tagProperties)
        markerHash = putTag(mapView: mapView, Tag: tagProperties)
        putTagsinArray(MarkerHash: markerHash, FirebaseID: firebaseId)
        animateOutWithOptionalEffect(effect: true)
        descriptionTextField.text = ""
        PutMessageOnHeader(msg: registry.msgDropSuccess, color: registry.customGreen)
        putIconOnMap(activate: false)
        getDroppedIconByUser()
        
    }
    
    @IBAction func cancelComment(_ sender: Any) {
        animateOutWithOptionalEffect(effect: true)
        descriptionTextField.text = ""
        putIconOnMap(activate: false)
        
    }
    
    // MARK: - Edition View
    
    @IBAction func changeDescription(_ sender: Any) {
        ref.child(selectedTagId!).updateChildValues(["description": newDescriptionTextField.text!])
        fetchTag(MarkerHash: selectedTag.hash)
        animateOutWithOptionalEffect(effect: false)
        
    }
    
    @IBAction func deleteEvent(_ sender: Any) {
        let annotations = self.mapView.annotations!
        
        mapView.removeAnnotations(annotations)
        isUserDeletingTag = true
        removeTag()
        animateOutWithOptionalEffect(effect: false)
        animateOutWithOptionalEffect(effect: true)
        PutMessageOnHeader(msg: registry.msgDeleteSuccess, color: registry.customGreen)
        getDroppedIconByUser()
        
    }
    
    @IBAction func closeEdition(_ sender: Any) {
        animateOutWithOptionalEffect(effect: false)

    }

    // MARK: - Online Tags
    
    /*
     * Get the amount of markers dropped by the current logged user.
     */
    func getDroppedIconByUser() {
        let currentUser = Auth.auth().currentUser?.uid
        let trace = Performance.startTrace(name: registry.trace11)

        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                var droppedIcons = 0
                for tag in snapshot.children.allObjects as! [DataSnapshot] {
                    let data = tag.value as? NSDictionary
                    let user = data?["user"] as? String
                    if currentUser == user {
                        droppedIcons += 1
                        
                    }
                }
                self.droppedIconNumber = droppedIcons
                trace?.stop()
            }
        }) { (error) in
            trace?.stop()
            print(error.localizedDescription)
            
        }
    }
    
    /*
     * Add markers on the map depending of its type from a tag id.
     */
    @discardableResult func putTag(mapView: MGLMapView, Tag: Tag) -> Int {
        let marker = MGLPointAnnotation()
        marker.coordinate.latitude = Tag.latitude!
        marker.coordinate.longitude = Tag.longitude!
        
        switch Tag.id {
        case 0:
            marker.title = NSLocalizedString("jellyfishs", comment: "")
            mapView.addAnnotation(marker)
        case 1:
            marker.title = NSLocalizedString("divers", comment: "")
            mapView.addAnnotation(marker)
        case 2:
            marker.title = NSLocalizedString("waste", comment: "")
            mapView.addAnnotation(marker)
        case 3:
            marker.title = NSLocalizedString("warning", comment: "")
            mapView.addAnnotation(marker)
        case 4:
            marker.title = NSLocalizedString("dolphins", comment: "")
            mapView.addAnnotation(marker)
        case 5:
            marker.title = NSLocalizedString("destination", comment: "")
            mapView.addAnnotation(marker)
        default:
            print("Error in func putTag")
            
        }
        return marker.hash
    }
    
    /*
     * Add the marker hash to the hash list and the marker id from the id list.
     */
    func putTagsinArray(MarkerHash: Int, FirebaseID: String) {
        tagIds.append(FirebaseID)
        tagHashs.append(MarkerHash)
        
    }
    
    /*
     * Retrieve all the markers from database.
     */
    func getTagsFromServer(mapView: MGLMapView) {
        let trace = Performance.startTrace(name: registry.trace12)
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
                    let upvote = data?["upvote"] as? Int
                    let downvote = data?["downvote"] as? Int
                    let contributors = data?["contributors"] as? [String:Int]
                    var markerHash: Int
                    markerHash = self.putTag(mapView: mapView, Tag: Tag(description: description, id: id, latitude: x, longitude: y, time: time, user: user, timestamp: timestamp, upvote: upvote, downvote: downvote, contributors: contributors))
                    self.putTagsinArray(MarkerHash: markerHash, FirebaseID: tag.key)
                    trace?.stop()
                    
                }
            }
        }) { (error) in
            trace?.stop()
            print(error.localizedDescription)
            
        }
    }
    
    /*
     * Observe child addition or deletion from background.
     */
    func syncData() {
        ref.observe(.childAdded, with: { (snapshot) -> Void in
            if (self.isUserAddingTag == false) {
                self.tagProperties.description = snapshot.childSnapshot(forPath:"description").value as? String
                self.tagProperties.id = snapshot.childSnapshot(forPath:"groupId").value as? Int
                self.tagProperties.latitude = snapshot.childSnapshot(forPath:"latitude").value as? Double
                self.tagProperties.longitude = snapshot.childSnapshot(forPath:"longitude").value as? Double
                let markerHash = self.putTag(mapView: self.mapView, Tag: self.tagProperties)
                self.putTagsinArray(MarkerHash: markerHash, FirebaseID: snapshot.key)
                
            }
            self.isUserAddingTag = false
        })
            
        ref.observe(.childRemoved, with: { (snapshot) -> Void in
            if (self.isUserDeletingTag == false) {
                let Tag_id = snapshot.key
                
                var count = 0
                while (self.tagIds[count] != Tag_id) {
                    count = count + 1
                
                }
                let annotations = self.mapView.annotations
                for annotation in annotations! {
                    if annotation.hash == self.tagHashs[count] { // TODO correct bug
                        let allAnnotations = self.mapView.annotations!
                        
                        self.mapView.removeAnnotations(allAnnotations)
                        self.tagHashs.remove(at: count)
                        self.tagIds.remove(at: count)
                        self.reloadData()
                        break
                        
                    }
                }
            }
            self.isUserDeletingTag = false
            
        })
    }
    
    /*
     * Create the marker on the database and return its firebase id.
     */
    func saveTags(Tag: Tag) -> String {
        let key = self.ref.childByAutoId().key
        let TagFirebase: [String: Any] = [
            "groupId": Tag.id as Any,
            "description": Tag.description as Any,
            "latitude": Tag.latitude as Any,
            "longitude": Tag.longitude as Any,
            "time": Tag.time as Any,
            "user": Tag.user as Any,
            "timestamp": Tag.timestamp as Any,
            "upvote": Tag.upvote as Any,
            "downvote": Tag.downvote as Any,
            "contributors": Tag.contributors as Any
        ]
        
        self.ref.child(key!).setValue(TagFirebase)
        return key!
        
    }
    
    /*
     * Remove a marker from the hash list and the tag id list then reload data.
     */
    func removeTag() {
        var count = 0
        while (tagIds[count] != selectedTagId!) {
            count = count + 1
        
        }
        self.tagHashs.remove(at: count)
        self.tagIds.remove(at: count)
        ref.child(selectedTagId!).removeValue { (error, ref) in
            if error != nil {
                print("Failed to delete tag: ", error!)
                return
                
            }
        }
        reloadData()
    }
    
    /*
     * Put every markers from the database on the map.
     */
    func reloadData() {
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
                    let upvote = data?["upvote"] as? Int
                    let downvote = data?["downvote"] as? Int
                    let contributors = data?["contributors"] as? [String:Int]
                    self.putTag(mapView: self.mapView, Tag: Tag(description: description, id: id, latitude: x, longitude: y, time: time, user: user, timestamp: timestamp, upvote: upvote, downvote: downvote, contributors: contributors))

                }
            }
        }) { (error) in
            print(error.localizedDescription)

        }
    }
    
    // MARK: - Description View
    
    /*
     * Retrieve marker's data from its hash and determine if the logged user
     * has already rate it.
     */
    func fetchTag(MarkerHash: Int) {
        var count = 0
        let hasDoneWork = false
        
        while (tagHashs[count] != MarkerHash) {
            if (tagHashs[count] != tagHashs.last) {
                count = count + 1
            } else {
                viewStacked = userDescriptionView
                animateInWithOptionalEffect(view: userDescriptionView, effect: true)
                fetchUserDescription()
                return
            }
        }
        
        viewStacked = descriptionView
        animateInWithOptionalEffect(view: descriptionView, effect: true)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                for tag in snapshot.children.allObjects as! [DataSnapshot] {
                    if (self.tagIds[count] == tag.key && hasDoneWork == false) {
                        let data = tag.value as? NSDictionary
                        let id  = data?["groupId"] as? Int
                        let description = data?["description"] as? String
                        let time = data?["time"] as? String
                        let user = data?["user"] as? String
                        let upvote = data?["upvote"] as? Int
                        let downvote = data?["downvote"] as? Int
                        let contributors = data?["contributors"] as? [String:Int]
                        
                        if description!.isEmpty == false {
                            self.newDescriptionTextField.text = description
                            
                        }
                    
                        self.timeLabel.text = self.weather.getPastTime(for: self.weather.getDateFromString(time: time!))
                        self.selectedTagId = tag.key
                        self.selectedTagUserId = user
                        self.descriptionLabel.text = description
                        self.upvotedCounter.text = "\(upvote ?? 0)"
                        self.downvotedCounter.text = "\(downvote ?? 0)"
                        
                        if user != Auth.auth().currentUser?.uid {
                            self.editButton.isEnabled = false
                            self.editButton.isHidden = true
                            self.getUserNameById(userId: user!)
                            /* unrated event */
                            self.setDescriptionViewFromRatingState(isUpvoted: false, isDownvoted: false, isUserEvent: false, isUnrated: true)
                            if (contributors != nil) {
                                for contributor in contributors! {
                                    if contributor.key == Auth.auth().currentUser?.uid {
                                        switch contributor.value {
                                        /* upvoted event */
                                        case 1:
                                            self.setDescriptionViewFromRatingState(isUpvoted: true, isDownvoted: false, isUserEvent: false, isUnrated: false)
                                            break
                                        /* downvoted event */
                                        case 2:
                                            self.setDescriptionViewFromRatingState(isUpvoted: false, isDownvoted: true, isUserEvent: false, isUnrated: false)
                                            break
                                        /* user event */
                                        default:
                                            print("Error: uid does not fit.")
                                            self.setDescriptionViewFromRatingState(isUpvoted: false, isDownvoted: false, isUserEvent: true, isUnrated: false)
                                            break
                                            
                                        }
                                    }
                                }
                            }
                        } else {
                            /* user event */
                            self.setDescriptionViewFromRatingState(isUpvoted: false, isDownvoted: false, isUserEvent: true, isUnrated: false)
                            
                        }
                        self.setDescriptionViewById(id: id!, description: description!)
                        
                    }
                }
            }
        }) { (error) in
            print("Error: ", error.localizedDescription)
            
        }
    }
    
    /*
     * Set the rating button and the description view of an icon depending of its owner.
     */
    func setDescriptionViewFromRatingState(isUpvoted: Bool, isDownvoted: Bool, isUserEvent: Bool, isUnrated: Bool) {
        if (isUpvoted == true) {
            self.thumbUpView.backgroundColor = self.registry.customFlashGreen
            self.thumbDownView.backgroundColor = self.registry.customLightGrey
            self.thumbUpIcon.tintColor = self.registry.customWhite
            self.thumbDownIcon.tintColor = self.registry.customDarkGrey
            self.upVoteButton.isEnabled = false
            self.downVoteButton.isEnabled = false
            self.ratedLabel.text = NSLocalizedString("alreadyRated", comment: "")
            self.ratingStackView.isHidden = false
            self.editButton.isHidden = true
            
        }
        if (isDownvoted == true) {
            self.thumbDownView.backgroundColor = self.registry.customRed
            self.thumbUpView.backgroundColor = self.registry.customLightGrey
            self.thumbDownIcon.tintColor = self.registry.customWhite
            self.thumbUpIcon.tintColor = self.registry.customDarkGrey
            self.upVoteButton.isEnabled = false
            self.downVoteButton.isEnabled = false
            self.ratedLabel.text = NSLocalizedString("alreadyRated", comment: "")
            self.ratingStackView.isHidden = false
            self.editButton.isHidden = true
            
        }
        if (isUserEvent == true) {
            self.userLabel.text = NSLocalizedString("userDroppedIt", comment: "")
            self.editButton.isEnabled = true
            self.editButton.isHidden = false
            self.thumbDownView.backgroundColor = self.registry.customLightGrey
            self.thumbUpView.backgroundColor = self.registry.customLightGrey
            self.thumbDownIcon.tintColor = self.registry.customDarkGrey
            self.thumbUpIcon.tintColor = self.registry.customDarkGrey
            self.upVoteButton.isEnabled = false
            self.downVoteButton.isEnabled = false
            self.ratedLabel.isHidden = true
            self.ratingStackView.isHidden = true
            
        }
        if (isUnrated == true) {
            self.thumbUpView.backgroundColor = self.registry.customLightGrey
            self.thumbDownView.backgroundColor = self.registry.customLightGrey
            self.thumbUpIcon.tintColor = self.registry.customDarkGrey
            self.thumbDownIcon.tintColor = self.registry.customDarkGrey
            self.upVoteButton.isEnabled = true
            self.downVoteButton.isEnabled = true
            self.ratedLabel.text = ""
            self.ratingStackView.isHidden = false
            self.editButton.isHidden = true
            
        }
    }
    
    /*
     * Set the image and a default label of a description's icon depending of its groupId.
     */
    func setDescriptionViewById(id: Int, description: String) {
        switch id {
        case 0:
            self.eventImage.image = self.registry.eventJellyfishs
            self.eventLabel.text = NSLocalizedString("jellyfishs", comment: "")
            if description.isEmpty {
                self.descriptionLabel.text = self.registry.descJellyfishs
            }
        case 1:
            self.eventImage.image = self.registry.eventDivers
            self.eventLabel.text = NSLocalizedString("divers", comment: "")
            if description.isEmpty {
                self.descriptionLabel.text = self.registry.descDivers
            }
        case 2:
            self.eventImage.image = self.registry.eventWaste
            self.eventLabel.text = NSLocalizedString("waste", comment: "")
            if description.isEmpty {
                self.descriptionLabel.text = self.registry.descWaste
            }
        case 3:
            self.eventImage.image = self.registry.eventWarning
            self.eventLabel.text = NSLocalizedString("warning", comment: "")
            if description.isEmpty {
                self.descriptionLabel.text = self.registry.descWarning
            }
        case 4:
            self.eventImage.image = self.registry.eventDolphins
            self.eventLabel.text = NSLocalizedString("dolphins", comment: "")
            if description.isEmpty {
                self.descriptionLabel.text = self.registry.descDolphins
            }
        case 5:
            self.eventImage.image = self.registry.eventDestination
            self.eventLabel.text = NSLocalizedString("destination", comment: "")
            if description.isEmpty {
                self.descriptionLabel.text = self.registry.descDestination
            }
        default:
            print("Error deprecated tag.")
            
        }
    
    }
    
    /*
     * Retrieve the icon's owner from the userID in order to display
     * it on the description view of the icon.
     */
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
            self.userLabel.text = NSLocalizedString("droppedBy", comment: "") + userNameFromData + "."
            trace?.stop()
            
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
        mapView.deselectAnnotation(annotation, animated: false)
        /*viewStacked = descriptionView // todo
        animateInWithOptionalEffect(view: descriptionView, effect: true)*/
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
        
        if annotation.title == NSLocalizedString("dolphins", comment: "") {
            var image = UIImage(named: "pin_dolphins")!
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
            marker = MGLAnnotationImage(image: image, reuseIdentifier: "Dolphins")
            
        } else if annotation.title == NSLocalizedString("jellyfishs", comment: "") {
            var image = UIImage(named: "pin_jellyfishs")!
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
            marker = MGLAnnotationImage(image: image, reuseIdentifier: "Jellyfishs")
            
        } else if annotation.title == NSLocalizedString("divers", comment: "") {
            var image = UIImage(named: "pin_divers")!
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
            marker = MGLAnnotationImage(image: image, reuseIdentifier: "Divers")
            
        } else if annotation.title == NSLocalizedString("destination", comment: "") {
            var image = UIImage(named: "pin_destination")!
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
            marker = MGLAnnotationImage(image: image, reuseIdentifier: "Destination")
            
        } else if annotation.title == NSLocalizedString("warning", comment: "") {
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
        let pressRecognizer = UITapGestureRecognizer(target: self, action: #selector(pressOnMap))
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
    
    @objc func pressOnMap(_ recognizer: UITapGestureRecognizer) {
        if (self.isInside == true) {
            let pressScreenCoordinates = recognizer.location(in: mapView)
            let pressMapCoordinates = mapView.convert(pressScreenCoordinates, toCoordinateFrom: mapView)
            tagProperties.latitude = pressMapCoordinates.latitude
            tagProperties.longitude = pressMapCoordinates.longitude
            let distance = self.mapView.userLocation!.coordinate.distance(to: pressMapCoordinates)

            if distance < 10000 {
                let point = mapView.convert(pressMapCoordinates, toPointTo: mapView)
                let features = mapView.visibleFeatures(at: point, styleLayerIdentifiers: ["water"])
                if (features.description != "[]") {
                    self.viewStacked = commentView
                    self.animateInWithOptionalEffect(view: commentView, effect: true)
                    
                } else {
                    self.PutMessageOnHeader(msg: self.registry.msgEarthLimit, color: self.registry.customRed)
                    
                }
            } else {
                self.PutMessageOnHeader(msg: self.registry.msgDistanceLimit, color: self.registry.customRed)
                
            }
        }
    }
    
    func putWeatherOnMap(activate: Bool) {
        let pressRecognizerWithoutDisplay = UITapGestureRecognizer(target: self, action: #selector(pressOnMapWithoutDisplay))
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

    @objc func pressOnMapWithoutDisplay(_ recognizer: UITapGestureRecognizer) {
        if (self.isInside == true) {
            let pressScreenCoordinates = recognizer.location(in: mapView)
            let pressMapCoordinates = mapView.convert(pressScreenCoordinates, toCoordinateFrom: mapView)
            let longitude = pressMapCoordinates.longitude
            let latitude = pressMapCoordinates.latitude
            self.getWeatherFromSelectedLocation(long: longitude, lat: latitude)
            
            let point = mapView.convert(pressMapCoordinates, toPointTo: mapView)
            let features = mapView.visibleFeatures(at: point, styleLayerIdentifiers: ["water"])
            if (features.description != "[]") {
                self.viewStacked = self.weatherIconView
                self.animateInWithOptionalEffect(view: weatherIconView, effect: true)
                self.putWeatherOnMap(activate: false)
                
            } else {
                self.PutMessageOnHeader(msg: self.registry.msgDistanceLimit, color: self.registry.customRed)
                
            }
        }
    }
    
    // MARK: - Weather
    
    /*
     * Get weather from latitude and longitude.
     */
    func getWeatherFromSelectedLocation(long: Double, lat: Double) {
        let param: Parameters = [
            "lat": String(lat),
            "lng": String(long)]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": self.registry.apiBearer ]
        
        let trace = Performance.startTrace(name: registry.trace2)
        _ = AF.request(self.registry.apiUrl, method: .get, parameters: param, encoding: URLEncoding.default, headers: headers).validate(statusCode: 200..<500).responseJSON(completionHandler: {response in
            switch response.result {
            case .success(let value):
                let jsonObject = JSON(value)
                print(jsonObject)
                self.transformData(rawData: jsonObject)
            case .failure(let error):
                print(error)
            }})
        trace?.stop()
        
    }
    
    /*
     * Get uv and weather data from json.
     */
    func transformData(rawData: JSON) {
        // get uv index
        let uvData = rawData["uv"]
        let uvAsJson = JSON(uvData)
        if let uvIndex = uvAsJson["value"].double {
            self.uvGlobal = self.weather.analyseUvIndex(uvIndex: uvIndex)
            
        } else {
            print(uvAsJson["value"].error!)
            
        }
        // get weather
        let data = rawData["weather"]
        let dataAsJson = JSON(data)
        do {
            let weather = Weather(weatherData: dataAsJson)
            self.didGetWeather(weather: weather)
            
        } catch let jsonError as NSError {
            self.didNotGetWeather(error: jsonError)
            
        }
    }
    
    /*
     * If the weather data are gotten, set the labels of the weather marker.
     */
    func didGetWeather(weather: Weather) {
        DispatchQueue.main.async {
            self.weatherImage.image = self.weather.analyseDescription(weather: weather, registry: self.registry)
            
            if (UserDefaults.standard.object(forKey: "choosen_degree") as AnyObject) .isEqual("C") {
                self.airTemperatureLabel.text = "\(Int(round(weather.tempCelsius))) °C"
            } else if (UserDefaults.standard.object(forKey: "choosen_degree") as AnyObject) .isEqual("F") {
                self.airTemperatureLabel.text = "\(Int(round(weather.tempCelsius) * 1.8 + 32)) °F"
            } else {
                self.airTemperatureLabel.text = "\(Int(round(weather.tempCelsius))) °C"
            }
            
            self.weatherLabel.text = weather.weatherDescription
            
            self.weatherLongitudeLabel.text = String(format:"%f", weather.longitude)
            self.weatherLatitudeLabel.text = String(format:"%f", weather.latitude)
            
            let formatter = DateFormatter()
            formatter.dateFormat = NSLocalizedString("dateFormat", comment: "")
            formatter.locale = Locale(identifier: NSLocalizedString("localeIdentifier", comment: ""))
            let sunriseDate: String = formatter.string(from: weather.sunrise)
            self.sunriseLabel.text = sunriseDate
            let sunsetDate: String = formatter.string(from: weather.sunset)
            self.sunsetLabel.text = sunsetDate
            
            self.rainRiskLabel.text = "\(weather.cloudCover) %"
            self.waterTemperatureLabel.text = "--"
            
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
    
    /*
     * If the weather data aren't gotten, set the labels of the weather marker
     * with default values.
     */
    func didNotGetWeather(error: NSError) {
        DispatchQueue.main.async {
            self.airTemperatureLabel.text = "--"
            self.weatherLabel.text = "--"
            self.sunriseLabel.text = "--"
            self.sunsetLabel.text = "--:--"
            self.rainRiskLabel.text = "-- %"
            self.waterTemperatureLabel.text = "--"
            self.windLabel.text = "-- km/h"
            self.humidityLabel.text = "-- %"
            self.visibilityLabel.text = "-- km"
            self.uvLabel.text = "--"
            
        }
        print(error)
        
    }
}

// MARK: - Custom Class

class CustomUserLocationAnnotationView: MGLUserLocationAnnotationView {
    let size: CGFloat = 48
    var dot: CALayer!
    var arrow: CAShapeLayer!
    
    /*
     * Update is a method inherited from MGLUserLocationAnnotationView. It updates the appearance
     * of the user location annotation when needed. This can be called many times a second, so be
     * careful to keep it lightweight.
     */
    override func update() {
        if frame.isNull {
            frame = CGRect(x: 0, y: 0, width: size, height: size)
            return setNeedsLayout()
            
        }
        /* check whether we have the user’s location yet. */
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
        /* This dot forms the base of the annotation. */
        if dot == nil {
            dot = CALayer()
            dot.bounds = CGRect(x: 0, y: 0, width: size, height: size)
            /* Use CALayer’s corner radius to turn this layer into a circle. */
            dot.cornerRadius = size / 2
            dot.backgroundColor = super.tintColor.cgColor
            dot.borderWidth = 4
            dot.borderColor = UIColor.white.cgColor
            layer.addSublayer(dot)
            
        }
        /* This arrow overlays the dot and is rotated with the user’s heading. */
        if arrow == nil {
            arrow = CAShapeLayer()
            arrow.path = arrowPath()
            arrow.frame = CGRect(x: 0, y: 0, width: size / 2, height: size / 2)
            arrow.position = CGPoint(x: dot.frame.midX, y: dot.frame.midY)
            arrow.fillColor = dot.borderColor
            layer.addSublayer(arrow)
            
        }
    }
    
    /*
     * Calculate the vector path for an arrow, for use in a shape layer.
     */
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
