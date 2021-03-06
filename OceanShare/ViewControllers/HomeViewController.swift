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
    var stackedLongitude: String!
    var stackedLatitude: String!
    var mustBeenDisplayed = true
    var isLocationActivated: Bool!
    
    /*  Harbor properties */
    
    var HarborCoord = [String]()
    var HarborName = [String]()
    var HarborNumber = [String]()
    
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
    
    /* user properties */
    weak var timer: Timer?
    var userIds = [String]()
    var userHashs = [Int]()
    
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
    let skeleton = Skeleton()
    let weather = Weather.self
    let currentUser = User.self

    // MARK: - Outlets
    
    /* map view */
    @IBOutlet weak var centerIcon: UIImageView!
    @IBOutlet weak var centerView: DesignableButton!
    @IBOutlet weak var speedView: DesignableView!
    @IBOutlet weak var speedValue: UILabel!
    @IBOutlet weak var speedMetric: UILabel!
    @IBOutlet weak var speedIcon: UIImageView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var messageLabel: UITextView!
    @IBOutlet weak var mapItem: UITabBarItem!
    @IBOutlet weak var warningView: UIView!
    
    /* icon view */
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var iconViewJellyfishs: UILabel!
    @IBOutlet weak var iconViewDivers: UILabel!
    @IBOutlet weak var iconViewWaste: UILabel!
    @IBOutlet weak var iconViewWarning: UILabel!
    @IBOutlet weak var iconViewDolphins: UILabel!
    @IBOutlet weak var iconViewDestination: UILabel!
    @IBOutlet weak var iconViewBuoys: UILabel!
    @IBOutlet weak var iconViewPatrols: UILabel!
    @IBOutlet weak var iconViewFishes: UILabel!
    @IBOutlet weak var iconViewWeather: UILabel!
    @IBOutlet weak var closeIcon: UIImageView!
    @IBOutlet weak var buttonMenu: DesignableButton!
    @IBOutlet weak var weatherLock: DesignableView!
    
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
    @IBOutlet weak var skeletonName: DesignableView!
    @IBOutlet weak var messagePadlockView: DesignableView!
    
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
    
    /* Visual effects */
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /* Force the light mode */
        overrideUserInterfaceStyle = .light
        /* Check if geolocation is enable */
        NotificationCenter.default.addObserver(self, selector:#selector(checkLocalisationService), name: UIApplication.willEnterForegroundNotification, object: nil)
        ref = Database.database().reference().child("markers")
        userRef = Database.database().reference().child("users")
        syncData()
        setupInfo()
        setupView()

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocalisationService()
        getDisplayableUsers()
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(HomeViewController.getDisplayableUsers), userInfo: nil, repeats: true)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupCompass()
        
    }
    
    // MARK: - Setup

    /**
     - Description - Setup embeded views from home view controller.
     */
    func setupView() {
        /* blur effect */
        effect = visualEffectView.effect
        visualEffectView.effect = nil
        visualEffectView.isHidden = true
        /* mapview setup */
        mapView = MGLMapView(frame: view.bounds, styleURL: URL(string: registry.mapUrl))
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.logoView.isHidden = true
        mapView.attributionButton.isHidden = true
        mapView.userTrackingMode = .followWithHeading
        mapView.showsUserHeadingIndicator = true
        putHarbors()
        getTagsFromServer(mapView: self.mapView)
        /* icon setup */
        setupCustomIcons()
        /* set localized labels */
        setupLocalizedStrings()
        /* add the layers in the right order */
        view.addSubview(mapView)
        view.addSubview(warningView)
        view.addSubview(headerView)
        view.addSubview(centerView)
        view.addSubview(buttonMenu)
        view.addSubview(speedView)
        view.addSubview(visualEffectView)
        
    }
    
    /**
     - Description - Setup user's longitude and latitude from location manager.
     */
    func setupInfo() {
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            //locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.startUpdatingLocation()
            
        } else {
            checkLocalisationService()
            
        }
    }
    
    /**
     - Description - Setup translated labels.
     */
    func setupLocalizedStrings() {
        /* icon view */
        iconViewJellyfishs.text = NSLocalizedString("iconViewJellyfishs", comment: "")
        iconViewDivers.text = NSLocalizedString("iconViewDivers", comment: "")
        iconViewWaste.text = NSLocalizedString("iconViewWaste", comment: "")
        iconViewWarning.text = NSLocalizedString("iconViewWarning", comment: "")
        iconViewDolphins.text = NSLocalizedString("iconViewDolphins", comment: "")
        iconViewDestination.text = NSLocalizedString("iconViewDestination", comment: "")
        iconViewWeather.text = NSLocalizedString("iconViewWeather", comment: "")
        iconViewBuoys.text = NSLocalizedString("iconViewBuoys", comment: "")
        iconViewPatrols.text = NSLocalizedString("iconViewPatrols", comment: "")
        iconViewFishes.text = NSLocalizedString("iconViewFishes", comment: "")
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
    
    /**
     - Description - Setup custom icons.
     */
    func setupCustomIcons() {
        /* map view */
        centerIcon.image = centerIcon.image!.withRenderingMode(.alwaysTemplate)
        centerIcon.tintColor = registry.customDarkBlue
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
    
    /**
     - Description - Setup the compass from mapview.
     */
    func setupCompass() {
        var centerPoint = mapView.compassView.center
        centerPoint.y = 65
        mapView.compassView.center = centerPoint
        
    }
    
    /**
     - Description - Check if the user is premium or not and displays or not the offers.
     */
    func fetchSubscribtion() {
        let currentDate = NSDate() as Date
        
        if Defaults.getUserDetails().subEnd.timeIntervalSince(currentDate).sign == FloatingPointSign.minus {
            print("-> not premium")
            weatherLock.isHidden = false
            messagePadlockView.isHidden = false
            
        } else {
            print("-> premium")
            weatherLock.isHidden = true
            messagePadlockView.isHidden = true
            
        }
    }
    
    // MARK: - Location manager
    
    /**
     - Description - Real time location manager. Update user's lalitude and longitude.
     - Inputs - manager `CLLocationManager` & locations `[CLLocation]`
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let longitude = Double(round(10000*locValue.longitude)/10000).clean
        let latitude = Double(round(10000*locValue.latitude)/10000).clean
        let location = locations[locations.count - 1]
    
        switch UIApplication.shared.applicationState {
            case .background, .inactive:
                let trace = Performance.startTrace(name: self.registry.trace13)
                let userActive = ["user_active": false]
                self.userRef.child("\(uid)/preferences").updateChildValues(userActive)
                trace?.stop()
            case .active:
                let trace = Performance.startTrace(name: self.registry.trace14)
                let userActive = ["user_active": true]
                self.userRef.child("\(uid)/preferences").updateChildValues(userActive)
                
                if (longitude != self.stackedLongitude) {
                    let userLongitude: [String: Any] = ["longitude": String(format:"%f", locValue.longitude) as Any]
                    self.userRef.child("\(uid)/location").updateChildValues(userLongitude)
                    self.stackedLongitude = longitude
                    
                }
                
                if (latitude != self.stackedLatitude) {
                    let userLattitude: [String: Any] = ["latitude": String(format:"%f", locValue.latitude) as Any]
                    self.userRef.child("\(uid)/location").updateChildValues(userLattitude)
                    self.stackedLatitude = latitude
                    
                }
                trace?.stop()
            default:
                break
        }
        
        if location.horizontalAccuracy > 0 {
            if (location.speed < 1) {
                speedView.isHidden = true
                warningView.isHidden = true
                mustBeenDisplayed = true
                
            } else {
                speedView.isHidden = false
                //locationManager.stopUpdatingLocation()
                let speedKilometersHours = location.speed * 3.6
                let speedNds = speedKilometersHours * 0.54
                speedValue.text = String(round(speedNds).clean)
                speedMetric.text = "Nds"
                if (speedNds > 5) {
                    if (mustBeenDisplayed == true) {
                        mustBeenDisplayed = false
                        warningView.isHidden = false
                        
                    }
                } else {
                    mustBeenDisplayed = true
                    warningView.isHidden = true
                    
                }
            }
        }
    }
    
    /**
     - Description - Display an alert when geolocation is disable or inactive.
     */
    func geolocationAlert() {
        let alertController = UIAlertController(title: NSLocalizedString("geolocAlert", comment: ""), message: NSLocalizedString("geolocAlertDesc", comment: ""), preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("geolocAlertOne", comment: ""), style: .default) { value in
            let path = UIApplication.openSettingsURLString
            guard let settingsURL = URL(string: path), !settingsURL.absoluteString.isEmpty else {
              return
                
            }
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
           
        })
        alertController.addAction(UIAlertAction(title: NSLocalizedString("geolocTwo", comment: ""), style: .cancel) { value in
            self.checkLocalisationService()
        })
        self.present(alertController, animated: true, completion: nil)
    }
    
    /**
     - Description - Check if geolocation is enable or active, if not calls the alert displayer function.
     */
    @objc func checkLocalisationService() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                    isLocationActivated = false
                    geolocationAlert()
                    print("-x Localisation disabled.")
                case .authorizedAlways, .authorizedWhenInUse:
                    if isLocationActivated == false {
                        isLocationActivated = true
                        dismiss(animated: false, completion: nil)
                        let mainTabBarController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
                        mainTabBarController.selectedViewController = mainTabBarController.viewControllers?[0]
                        self.present(mainTabBarController, animated: true,completion: nil)
                        print("~> Location is now activated.")
                    }
                    print("-> Localisation enabled.")
                @unknown default:
                break
            }
            } else {
                isLocationActivated = false
                geolocationAlert()
                print("-x Localisation disabled.")
        }
    }
    
    // MARK: - Animations
    
    /**
      - Description - Display a message on the header depending of interactions the user has with markers.
      - Inputs - msg `String` & color `UIColor` & error `Bool`
     */
    func PutMessageOnHeader(msg: String, color: UIColor, error: Bool) {
        headerView.backgroundColor = color
        messageLabel.text = msg
        if (error == false) {
            // todo: stop header sliding to the bottom before the previous one disapear

        }
        headerView.animShow()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.headerView.animHide()
        }
    }
    
    /**
     - Description - Animate the display of a view with optional blur effects.
     - Inputs - view `UIView` & effect `Bool`
     */
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
    
    /**
     - Description - Animate the closure of a view with optional blur effects.
     - Inputs - effect `Bool`
     */
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
    
    /**
     - Description - Hide the speed warning when the user tap on it.
     */
    @IBAction func hideWarning(_ sender: Any) {
        warningView.isHidden = true
        
    }
    
    /**
     - Description - Center the map to the user location.
     */
    @IBAction func centerMapToUser(_ sender: Any) {
        mapView.setCenter(mapView.userLocation!.coordinate, animated: true)
        
    }
    
    /**
     - Description - Open the icon menu.
     */
    @IBAction func openMenu(_ sender: Any) {
        viewStacked = iconView
        animateInWithOptionalEffect(view: iconView, effect: true)

        fetchSubscribtion()
        getDroppedIconByUser()
        
    }
    
    // MARK: - Icon View
    
    /**
     - Description - Hide the icon menu.
     */
    @IBAction func closeMenu(_ sender: Any) {
        animateOutWithOptionalEffect(effect: true)
        
    }
    
    /**
     - Description - Activate the medusa event from the icon menu.
     */
    @IBAction func medusaActivate(_ sender: Any) {
        eventActivator(eventId: 0, eventDescription: "Jellyfishs", eventMessage: self.registry.msgJellyfishs)
        
    }
    
    /**
    - Description - Activate the diver event from the icon menu.
    */
    @IBAction func diverActivate(_ sender: Any) {
        eventActivator(eventId: 1, eventDescription: "Divers", eventMessage: self.registry.msgDivers)
        
    }
    
    /**
    - Description - Activate the waste event from the icon menu.
    */
    @IBAction func wasteActivate(_ sender: Any) {
        eventActivator(eventId: 2, eventDescription: "Waste", eventMessage: self.registry.msgWaste)
        
    }
    
    /**
    - Description - Activate the warning event from the icon menu.
    */
    @IBAction func warningActivate(_ sender: Any) {
        eventActivator(eventId: 3, eventDescription: "Warning", eventMessage: self.registry.msgWarning)

    }
    
    /**
    - Description - Activate the dolphin event from the icon menu.
    */
    @IBAction func dolphinActivate(_ sender: Any) {
        eventActivator(eventId: 4, eventDescription: "Dolphins", eventMessage: self.registry.msgDolphins)
        
    }
    
    /**
    - Description - Activate the destination event from the icon menu.
    */
    @IBAction func destinationActivate(_ sender: Any) {
        eventActivator(eventId: 5, eventDescription: "Destination", eventMessage: self.registry.msgDestination)
        
    }
    
    /**
    - Description - Activate the buoy event from the icon menu.
    */
    @IBAction func buoyActivate(_ sender: Any) {
        eventActivator(eventId: 6, eventDescription: "Buoys", eventMessage: self.registry.msgBuoys)
        
    }
    
    /**
    - Description - Activate the patrol event from the icon menu.
    */
    @IBAction func patrolActivate(_ sender: Any) {
        eventActivator(eventId: 7, eventDescription: "Patrols", eventMessage: self.registry.msgPatrols)
        
    }
    
    /**
    - Description - Activate the fish event from the icon menu.
    */
    @IBAction func fishActivate(_ sender: Any) {
        eventActivator(eventId: 8, eventDescription: "Fishes", eventMessage: self.registry.msgFishes)
        
    }
    
    /**
    - Description - Activate the weather event from the icon menu.
    */
    @IBAction func weatherActivate(_ sender: Any) {
        animateOutWithOptionalEffect(effect: true)
        let currentDate = NSDate() as Date
        
        if Defaults.getUserDetails().subEnd.timeIntervalSince(currentDate).sign == FloatingPointSign.minus {
            print("-> not premium")
            let subViewController = self.storyboard?.instantiateViewController(withIdentifier: "SubscribtionViewController") as! SubscribtionViewController
            self.present(subViewController, animated: true,completion: nil)
       
        } else {
            print("-> premium")
            putWeatherOnMap(activate: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.PutMessageOnHeader(msg: self.registry.msgWeather, color: self.registry.customGreen, error: false)
                
            }
        }
    }
    
    /**
     - Description - Set the event properties to the icon that will be dropped and check the limit of event amount.
     - Inputs - eventId `Int`  & eventDescription `String` & eventMessage `String`
     */
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.PutMessageOnHeader(msg: eventMessage, color: self.registry.customGreen, error: false)
                
            }
        } else {
            animateOutWithOptionalEffect(effect: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.PutMessageOnHeader(msg: self.registry.msgEventLimit, color: self.registry.customRed, error: true)
                
            }
        }
    }
    
    // MARK: - User Description View
    
    /**
     - Description - Open the Subscribtion view controller from the message button.
     */
    @IBAction func openSubViewFromMessage(_ sender: Any) {
        animateOutWithOptionalEffect(effect: true)
        let subViewController = self.storyboard?.instantiateViewController(withIdentifier: "SubscribtionViewController") as! SubscribtionViewController
        self.present(subViewController, animated: true,completion: nil)
        
    }
    
    /**
     - Description - Close the user description view.
     */
    @IBAction func closeUserDescription(_ sender: Any) {
        animateOutWithOptionalEffect(effect: true)
        
    }
    
    /**
     - Description - Fetch user data to display on the user description view.
     */
    func fetchUserDescription() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        viewStacked = userDescriptionView
        animateInWithOptionalEffect(view: userDescriptionView, effect: true)
        
        userRef.child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot == snapshot {
                let userData = User(dataSnapshot: snapshot as DataSnapshot)
                self.userAvatarName.text = userData.name
                self.userAvatar.layer.cornerRadius = 41
                self.userAvatar.clipsToBounds = true
                
                _ = Storage.storage().reference()
                .child("profile_pictures")
                .child("\(String(describing: snapshot.key)).png")
                .downloadURL(completion: { (url, error) in
                if error != nil {
                    if userData.picture != nil {
                        self.userAvatar.image = userData.getUserPictureFromDatabase(user: userData)
                        
                    } else {
                        self.userAvatar.image = userData.getUserPictureFromNowhere(user: userData)
                        
                    }
                } else {
                    self.userAvatar.image = userData.getUserPictureFromStorage(user: userData, url: url!)
                    
                }})
            }
        })
        
    }

    // MARK: - Description View

    /**
     - Description - Close the description view.
     */
    @IBAction func closeDescription(_ sender: Any) {
        animateOutWithOptionalEffect(effect: true)
        
    }

    /**
     - Description - Open the edition view to modify the event.
     */
    @IBAction func editEvent(_ sender: Any) {
        overViewStacked = editionView
        animateInWithOptionalEffect(view: editionView, effect: false)
        
    }

    /**
     - Description - Downvote an event and check if the event has 3 or more downvotes. If it has, the function delete this event.
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
            self.downvotedCounter.text = "\(downVoteAmount + 1)"
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

    /**
     - Description - Upvote an event.
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
    
    /**
     - Set an optional description to the selected event before to drop it on the map.
     */
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.PutMessageOnHeader(msg: self.registry.msgDropSuccess, color: self.registry.customGreen, error: false)
        }
        putIconOnMap(activate: false)
        getDroppedIconByUser()
        
    }
    
    /**
     - Description - Cancel the optional description edition.
     */
    @IBAction func cancelComment(_ sender: Any) {
        animateOutWithOptionalEffect(effect: true)
        descriptionTextField.text = ""
        putIconOnMap(activate: false)
        
    }
    
    // MARK: - Edition View
    
    /**
     - Description - Change the optional event description of a dropped event.
     */
    @IBAction func changeDescription(_ sender: Any) {
        ref.child(selectedTagId!).updateChildValues(["description": newDescriptionTextField.text!])
        fetchTag(MarkerHash: selectedTag.hash)
        animateOutWithOptionalEffect(effect: false)
        
    }
    
    /**
     - Description - Delete a dropped event.
     */
    @IBAction func deleteEvent(_ sender: Any) {
        let annotations = self.mapView.annotations!
        
        mapView.removeAnnotations(annotations)
        isUserDeletingTag = true
        removeTag()
        animateOutWithOptionalEffect(effect: false)
        animateOutWithOptionalEffect(effect: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.PutMessageOnHeader(msg: self.registry.msgDeleteSuccess, color: self.registry.customGreen, error: false)
        }
        getDroppedIconByUser()
        
    }
    
    /**
     - Hide the edition view of a dropped event.
     */
    @IBAction func closeEdition(_ sender: Any) {
        animateOutWithOptionalEffect(effect: false)

    }

    // MARK: - Online Tags
    
    /**
     - Description - Get the amount of markers dropped by the current logged user.
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
    
    /**
     - Description - Add markers on the map depending of its type from a tag id.
     - Inputs - mapView `MLGMapView` & Tag `Tag`
     - Output - `Int` marker hash
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
        case 6:
            marker.title = NSLocalizedString("buoys", comment: "")
            mapView.addAnnotation(marker)
        case 7:
            marker.title = NSLocalizedString("patrols", comment: "")
            mapView.addAnnotation(marker)
        case 8:
            marker.title = NSLocalizedString("fishes", comment: "")
            mapView.addAnnotation(marker)
        default:
            print("Error in func putTag")
            
        }
        return marker.hash
    }
    
    /**
     - Description - Add the marker hash to the hash list and the marker id from the id list.
     - Inputs - MarkerHash `Int` & FirebaseID `String`
     */
    func putTagsinArray(MarkerHash: Int, FirebaseID: String) {
        tagIds.append(FirebaseID)
        tagHashs.append(MarkerHash)
        
    }
    
    /**
     - Description - Retrieve all the markers from database.
     - Inputs - mapView `MLGMapView`
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

    /**
     - Description - Observe child addition or deletion from background.
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
            self.getDisplayableUsers()
        })
    }
    
    /**
     - Description - Create the marker on the database and return its firebase id.
     - Inputs - Tag `Tag`
     - Output - `String` marker id
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

    /**
      - Description - Remove a marker from the hash list and the tag id list then reload data.
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
    
    /**
     - Description - Put every markers from the database on the map.
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

    /**
     - Description - Retrieve marker's data from its hash and determine if the logged user has already rate it.
     - Intputs - MarkerHash `Int`
     */
    func fetchTag(MarkerHash: Int) {
        var count = 0
        
        while (tagHashs[count] != MarkerHash) {
            if (tagHashs[count] != tagHashs.last) {
                count = count + 1
            } else {
                fetchUserDescription()
                return
            }
        }
        
        viewStacked = descriptionView
        animateInWithOptionalEffect(view: descriptionView, effect: true)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                for tag in snapshot.children.allObjects as! [DataSnapshot] {
                    if (self.tagIds[count] == tag.key) {
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
                                            print("Error in function fetchTag(): uid (\(String(describing: user))) does not fit.")
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
            print("Error in function fetchTag(): ", error.localizedDescription)
            
        }
    }
    
    /**
     - Description - Set the rating button and the description view of an icon depending of its owner.
     - Inputs - isUpvoted `Bool` & isDownvoted `Bool` & isUserEvent `Bool` & isUnrated `Bool`
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

    /**
     - Description - Set the image and a default label of a description's icon depending of its groupId.
     - Inputs - id `Int` & description `String`
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
        case 6:
            self.eventImage.image = self.registry.eventBuoys
            self.eventLabel.text = NSLocalizedString("Buoys", comment: "")
            if description.isEmpty {
                self.descriptionLabel.text = self.registry.descBuoys
        }
        case 7:
            self.eventImage.image = self.registry.eventPatrols
            self.eventLabel.text = NSLocalizedString("Patrols", comment: "")
            if description.isEmpty {
                self.descriptionLabel.text = self.registry.descPatrols
        }
        case 8:
            self.eventImage.image = self.registry.eventFishes
            self.eventLabel.text = NSLocalizedString("Fishes", comment: "")
            if description.isEmpty {
                self.descriptionLabel.text = self.registry.descFishes
        }
        default:
            print("Error deprecated tag.")
            
        }
    
    }

    /**
     - Description - Retrieve the icon's owner from the userID in order to display it on the description view of the icon.
     - Inputs - userId `String`
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
    
    // MARK: - Mapbox function
    
    /**
    - Description - Display the annotation.
    - Inputs - mapView `MGLMapView` & annotation `MGLAnnotation`
    - Output - `Bool` if annotation can be showed
    */
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true

    }
    
    /**
     - Description - Get a button on the annotation that open the annotation description view.
     - Inputs - mapView `MGLMapView` & annotation `MGLAnnotation`
     - Output - `UIView` description and button
     */
    func mapView(_ mapView: MGLMapView, rightCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
        return UIButton(type: .contactAdd)
        
    }

    /**
     - Description - Return true if the annotation is a user location, else return false.
     - Inputs - title `String`
     - Output - `Bool` is a user location or not
     */
    func isUserAnnotation(title: String) -> Bool {
        if (title == NSLocalizedString("gondola", comment: "")) ||
            (title == NSLocalizedString("sailing_boat", comment: "")) ||
            (title == NSLocalizedString("mini_yacht", comment: "")) ||
            (title == NSLocalizedString("yacht", comment: "")) {
            return true
            
        }
        return false
        
    }
    
    /**
     - Description - Get the data depending of the selected annotation.
     - Inputs - mapView `MGLMapView` & annotation `MGLAnnotation` & control `UIControl`
     */
    func mapView(_ mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
        mapView.deselectAnnotation(annotation, animated: false)
        if (isUserAnnotation(title: annotation.title!!)) {
            selectedTag = annotation
            fetchUserTag(MarkerHash: annotation.hash)
            
        } else if annotation.subtitle == NSLocalizedString("upToDate", comment: "") {
            displayAlert(title: getHarborName(long: annotation.coordinate.longitude, lat: annotation.coordinate.latitude), message: getHarborNumber(long: annotation.coordinate.longitude, lat: annotation.coordinate.latitude))
            
        } else {
            selectedTag = annotation
            fetchTag(MarkerHash: annotation.hash)
            
        }
    }
    
    /**
     - Description - Get the user location annotation.
     - Inputs - mapview `MGLMapView` & annotation `MGLAnnotation`
     - Output - `MGLAnnotationView` annotation location view
     */
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        if annotation is MGLUserLocation && mapView.userLocation != nil {
            return CustomUserLocationAnnotationView()
            
        }
        return nil
    }
    
    /**
     - Description - Define the annotation image depending of the marker type.
     - Inputs - mapview `MGLMapView` & annotation `MGLAnnotation`
     - Output - `MGLAnnotationImage` marker image
     */
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
            
        } else if annotation.title == NSLocalizedString("waste", comment: "") {
            var image = UIImage(named: "pin_waste")!
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
            marker = MGLAnnotationImage(image: image, reuseIdentifier: "Waste")
            
        } else if annotation.title == NSLocalizedString("buoys", comment: "") {
            var image = UIImage(named: "pin_buoy")!
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
            marker = MGLAnnotationImage(image: image, reuseIdentifier: "Buoys")
            
        } else if annotation.title == NSLocalizedString("patrols", comment: "") {
            var image = UIImage(named: "pin_guards")!
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
            marker = MGLAnnotationImage(image: image, reuseIdentifier: "Patrols")
            
        } else if annotation.title == NSLocalizedString("fishes", comment: "") {
            var image = UIImage(named: "pin_fishes")!
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
            marker = MGLAnnotationImage(image: image, reuseIdentifier: "Fishes")
            
        } else if annotation.title == NSLocalizedString("gondola", comment: "") {
            var image = UIImage(named: "pin_gondola")!
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/15, right: 0))
            marker = MGLAnnotationImage(image: image, reuseIdentifier: "Gondola")
            
        } else if annotation.title == NSLocalizedString("sailing_boat", comment: "") {
            var image = UIImage(named: "pin_sailing_boat")!
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/15, right: 0))
            marker = MGLAnnotationImage(image: image, reuseIdentifier: "Sailboat")
            
        } else if annotation.title == NSLocalizedString("mini_yacht", comment: "") {
            var image = UIImage(named: "pin_mini_yacht")!
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/15, right: 0))
            marker = MGLAnnotationImage(image: image, reuseIdentifier: "Yacht")
            
        } else if annotation.title == NSLocalizedString("yacht", comment: "") {
            var image = UIImage(named: "pin_yacht")!
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/15, right: 0))
            marker = MGLAnnotationImage(image: image, reuseIdentifier: "Mega yacht")
            
        } else if annotation.title == NSLocalizedString("harbour", comment: "") {
            var image = UIImage(named: "pin_harbour")!
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/15, right: 0))
            marker = MGLAnnotationImage(image: image, reuseIdentifier: "Harbour")
        } else {
            print()
            
        }
        
        return marker
    
    }
    
    // MARK: - Gesture Recognizers
    
    /**
     - Description - Add an icon on map.
     - Inputs - activate `Bool`
     */
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
    
    /**
     - Description - Detect the pressure on the screen when the user wants to drop a selected event.
     - Input - recognizer `UITapGestureRecognizer`
     */
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
                    self.PutMessageOnHeader(msg: self.registry.msgEarthLimit, color: self.registry.customRed, error: true)
                    
                }
            } else {
                self.PutMessageOnHeader(msg: self.registry.msgDistanceLimit, color: self.registry.customRed, error: true)
                
            }
        }
    }
    
    /**
     - Description - Open the weather description view on the map.
     - Inputs - activate `Bool`
     */
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

    /**
    - Description - Detect the pressure on the screen when the user wants to drop a weather event.
    - Input - recognizer `UITapGestureRecognizer`
    */
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
                self.PutMessageOnHeader(msg: self.registry.msgDistanceLimit, color: self.registry.customRed, error: true)
                
            }
        }
    }
    
    // MARK: - Weather
    
    /**
     - Description - Get weather from latitude and longitude.
     - Inputs - long `Double` & lat `Double`
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
                self.transformData(rawData: jsonObject)
            case .failure(let error):
                print(error)
            }})
        trace?.stop()
        
    }

    /**
    - Description - Get uv and weather data from json.
    - Intputs - rawData `JSON`
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
        let weather = Weather(weatherData: dataAsJson)
        self.didGetWeather(weather: weather)
    }
    
    /**
     - Description - If the weather data are gotten, set the labels of the weather marker.
     - Inputs - weather `Weather`
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
            
            self.weatherLabel.text = self.weather.analyseWeatherDescription(weather: weather, registry: self.registry)

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
    
    // MARK: - Users Handlers
    
    /**
     - Description - Hide the skeleton animation on the user description view.
     */
    func didFinishFetchingUserTag() {
        self.skeleton.turnOffSkeleton(image: self.userAvatar)
        self.skeleton.turnOffSkeletonContainer(view: self.skeletonName)

    }
    
    /**
     - Description - Get the data of the selected user.
     - Inputs - MarkerHash `Int`
     */
    func fetchUserTag(MarkerHash: Int) {
        var count = 0
        
        while (userHashs[count] != MarkerHash) {
            if (userHashs[count] != userHashs.last) {
                count = count + 1
            } else {
                fetchUserDescription()
                return
            }
        }
        fetchSubscribtion()
        viewStacked = userDescriptionView
        animateInWithOptionalEffect(view: userDescriptionView, effect: true)
        skeleton.turnOnSkeleton(image: userAvatar, cornerRadius: 41)
        skeleton.turnOnSkeletonContainer(view: skeletonName, cornerRadius: 15)
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                for user in snapshot.children.allObjects as! [DataSnapshot] {
                    if (self.userIds[count] == user.key) {
                        let userData = User(dataSnapshot: user as DataSnapshot)
                        self.userAvatarName.text = userData.name
                        self.userAvatar.layer.cornerRadius = 41
                        self.userAvatar.clipsToBounds = true
                        
                        _ = Storage.storage().reference()
                        .child("profile_pictures")
                        .child("\(String(describing: user.key)).png")
                        .downloadURL(completion: { (url, error) in
                        if error != nil {
                            if userData.picture != nil {
                                self.userAvatar.image = userData.getUserPictureFromDatabase(user: userData)
                                self.didFinishFetchingUserTag()
                                
                            } else {
                                self.userAvatar.image = userData.getUserPictureFromNowhere(user: userData)
                                self.didFinishFetchingUserTag()
                                
                            }
                        } else {
                            self.userAvatar.image = userData.getUserPictureFromStorage(user: userData, url: url!)
                            self.didFinishFetchingUserTag()
                            
                            }})
                    }
                }
            }
        })
    }
    
    /**
     - Description - Check if a user is displayable depending of its preferences.
     - Inputs - User `User`
     - Output - `Bool` is the user displayable or not
     */
    func isDisplayable(User: User) -> Bool {
        if (User.uid != Auth.auth().currentUser?.uid) {
            if (User.isActive == true) {
                if (User.ghostMode == false) {
                    if ((User.longitude != nil) && (User.latitude != nil)) {
                        if ((User.longitude != 0.0) && (User.latitude != 0.0)) {
                            let location = CLLocationCoordinate2D.init(latitude: User.latitude!, longitude: User.longitude!)
                            let point = mapView.convert(location, toPointTo: mapView)
                            let features = mapView.visibleFeatures(at: point, styleLayerIdentifiers: ["water"])
                            if (features.description != "[]") {
                                if (getMarkerDistance(lat1: (locationManager.location?.coordinate.latitude)!, long1: (locationManager.location?.coordinate.longitude)!, lat2: User.latitude! , long2: User.longitude!)) < 20000 {
                                    return true
                                    
                                }
                            } else {
                                print(User.name!, "is not on water.")
                                return false
                                
                            }
                        }
                    }
                }
            }
        }
        return false
        
    }

    /**
     - Description - Retrives displayable users from database.
     */
    @objc func getDisplayableUsers() {
        print("~> reload user location")
        removeUsersFromMap()
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                for user in snapshot.children.allObjects as! [DataSnapshot] {
                    let userData = User(dataSnapshot: user as DataSnapshot)
        
                    if (self.isDisplayable(User: userData) == true) {
                        var userHash: Int
                        userHash = self.putUsers(mapView: self.mapView, User: userData)
                        self.putUsersInArray(UserHash: userHash, FirebaseID: user.key)
                        
                    }
                }
            }
        })
    }
    
    /**
     - Description - Add a user on the map.
     - Inputs - mapView `MLGMapView` & User `User`
     - Output - `Int` user hash
     */
    @discardableResult func putUsers(mapView: MGLMapView, User: User) -> Int {
        let user = MGLPointAnnotation()
        user.coordinate.latitude = User.latitude!
        user.coordinate.longitude = User.longitude!
        
        switch User.boatId {
        case 1:
            user.title = NSLocalizedString("sailing_boat", comment: "")
            mapView.addAnnotation(user)
        case 2:
            user.title = NSLocalizedString("gondola", comment: "")
            mapView.addAnnotation(user)
        case 3:
            user.title = NSLocalizedString("mini_yacht", comment: "")
            mapView.addAnnotation(user)
        case 4:
            user.title = NSLocalizedString("yacht", comment: "")
            mapView.addAnnotation(user)
        default:
            print("Error in function putUsers(): no boat id found.")
            
        }
        return user.hash
    }
    
    /**
     - Description - Add a user in the user hash list and the user id list.
     */
    func putUsersInArray(UserHash: Int, FirebaseID: String) {
        userIds.append(FirebaseID)
        userHashs.append(UserHash)
        
    }
    
    /**
     - Description - Remove all the users on the map and empty the user hash list and the user id list.
     */
    func removeUsersFromMap() {
        let annotations = self.mapView.annotations
        
        if (userHashs.isEmpty == false) {
            for hash in userHashs {
                if ((annotations) != nil) {
                    for annotation in annotations! {
                        if (hash == annotation.hash) {
                            self.mapView.removeAnnotation(annotation)

                        }
                    }
                }
            }
        }
        userHashs.removeAll()
        userIds.removeAll()
        
    }
    
    struct Collection : Codable {
        let type : String
        let features : [Feature]
    }

    struct Feature : Codable {
        let type : String
        let properties : Properties
        let geometry : Geometry
    }
     
    struct Properties : Codable {
        let name : String
        let phone : String
        let adresse : String
        let description : String
        let place_Id : String
    }
    
    struct Geometry: Codable {
        let type: String
        let coordinates: [Double]
    }
     
    func getHarborName(long: Double, lat: Double) -> String {
        var i = 0
        let chain = String(long) + String(lat)
        for coord in self.HarborCoord {
            if coord == chain {
                return self.HarborName[i]
                
            }
            i = i + 1
        }
        return "error"
    }
      
    func getHarborNumber(long: Double, lat: Double) -> String {
        var i = 0
        let chain = String(long) + String(lat)
        for coord in self.HarborCoord {
            if coord == chain {
                return self.HarborNumber[i]
            }
            i = i + 1
        }
        return "error"
    }
      
    func getMarkerDistance(lat1: Double, long1: Double, lat2: Double, long2: Double) -> Double {
        let loc1 = CLLocationCoordinate2D.init(latitude: lat1, longitude: long1)
        let loc2 = CLLocationCoordinate2D.init(latitude: lat2, longitude: long2)
        return(loc1.distance(to: loc2))
      
    }
      
    func putHarbors(){
        guard let urlBar = Bundle.main.url(forResource: "harbour", withExtension: "geojson") else { return }
          
        do {
            let jsonData = try Data(contentsOf: urlBar)
            let result = try JSONDecoder().decode(Collection.self, from: jsonData)
            for feature in result.features {
                if (getMarkerDistance(lat1: (locationManager.location?.coordinate.latitude)!, long1: (locationManager.location?.coordinate.longitude)!, lat2: feature.geometry.coordinates[1] , long2: feature.geometry.coordinates[0])) < 20000 {
                    let harbor = MGLPointAnnotation()
                    harbor.coordinate.longitude = feature.geometry.coordinates[0]
                    harbor.coordinate.latitude = feature.geometry.coordinates[1]
                    harbor.title = NSLocalizedString("harbour", comment: "")
                    harbor.subtitle = NSLocalizedString("upToDate", comment: "")
                    mapView.addAnnotation(harbor)
                    HarborName.append(feature.properties.name)
                    HarborNumber.append(feature.properties.phone)
                    HarborCoord.append(String(feature.geometry.coordinates[0]) + String(feature.geometry.coordinates[1]))
      
                }
            }
        } catch { print("Error while parsing: \(error)") }
    }
    
    func displayAlert(title: String, message: String, restartDemo: Bool = false) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

// MARK: - User location annotation

class CustomUserLocationAnnotationView: MGLUserLocationAnnotationView {
    let size: CGFloat = 48
    var dot: CALayer!
    var arrow: CAShapeLayer!
    
    /**
     - Description - Update is a method inherited from MGLUserLocationAnnotationView.
                It updates the appearance of the user location annotation when needed.
                This can be called many times a second, so be careful to keep it lightweight.
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
    
    /**
     - Description - Update the direction of the arrow depending the user orientation.
     */
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
    
    /**
     - Description - Setup the user annotation.
     */
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
    
    /**
     - Description - Calculate the vector path for an arrow, for use in a shape layer.
     - Output - `CGPath` vector path
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

