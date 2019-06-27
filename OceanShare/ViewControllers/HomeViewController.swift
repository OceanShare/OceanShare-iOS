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
    // ------------------------------------------------------- //
    
    var ref: DatabaseReference!
    let storageRef = FirebaseStorage.Storage().reference()
    
    // MARK: - Variables
    // ------------------------------------------------------- //
    
    // view
    var effect: UIVisualEffect!
    var viewStacked: UIView?
    var overViewStacked: UIView?
    
    // tag properties
    var Tags_ids = [String]()
    var Tags_hashs = [Int]()
    var x_tag = 0.0
    var y_tag = 0.0
    var id_tag = "0"
    var description_tag = "."
    
    // map properties
    var goinside = true
    var cordinate: CLLocationCoordinate2D!
    var mapView: MGLMapView!
    var isInside = false
    
    // MARK: - Outlets
    // ------------------------------------------------------- //
    
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
    // ------------------------------------------------------- //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference().child("markers")
        // define the MLG map view and the user on this map
        setupView()
        // setup the visual effect
        effect = visualEffectView.effect
        visualEffectView.effect = nil
        visualEffectView.isHidden = true
    }
    
    // MARK: - Setup
    // ------------------------------------------------------- //
    
    func setupView() {
        // mapview setup
        mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        // enable heading tracking mode (arrow will appear)
        mapView.userTrackingMode = .followWithHeading
        // enable the permanent heading indicator which will appear when the tracking mode is not `.followWithHeading`.
        mapView.showsUserHeadingIndicator = true
        showTags(mapView: mapView)
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
    // ------------------------------------------------------- //
    
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
    // ------------------------------------------------------- //
    
    @IBAction func closeMenu(_ sender: Any) {
        animateOut()
    }
    
    @IBAction func openMenu(_ sender: Any) {
        self.viewStacked = iconView
        animateIn(view: iconView)
    }
    
    @IBAction func diverActivate(_ sender: Any) {
        self.id_tag = "Diver"
        self.description_tag = "Diver"
        self.Activate()
        animateOut()
    }
    
    @IBAction func wasteActivate(_ sender: Any) {
        self.id_tag = "Waste"
        self.description_tag = "Waste"
        self.Activate()
        animateOut()
    }
    
    @IBAction func medusaActivate(_ sender: Any) {
        self.id_tag = "Medusa"
        self.description_tag = "Medusa"
        self.Activate()
        animateOut()
    }
    
    @IBAction func dolphinActivate(_ sender: Any) {
        self.id_tag = "Dolphin"
        self.description_tag = "Dolphin"
        self.Activate()
        animateOut()
    }
    
    @IBAction func destinationActivate(_ sender: Any) {
        self.id_tag = "Position"
        self.description_tag = "Position"
        self.Activate()
        animateOut()
    }
    
    @IBAction func warningActivate(_ sender: Any) {
        self.id_tag = "SOS"
        self.description_tag = "SOS"
        self.Activate()
        animateOut()
    }
    
    @IBAction func weatherActivate(_ sender: Any) {
        // TODO: add the weather event
        self.Activate()
        animateOut()
    }
    
    
    // MARK: - Description View
    // ------------------------------------------------------- //
    
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
    // ------------------------------------------------------- //
    
    @IBAction func submitComment(_ sender: Any) {
        // TODO: submitting comment
    }
    
    @IBAction func cancelComment(_ sender: Any) {
        // TODO: cancel comment
    }
    
    // MARK: - Edition View
    // ------------------------------------------------------- //
    
    @IBAction func changeDescription(_ sender: Any) {
        // TODO: change description
    }
    
    @IBAction func deleteEvent(_ sender: Any) {
        // TODO: delete event
    }
    
    @IBAction func closeEdition(_ sender: Any) {
        animateOutWithoutBlur()
    }
    
    // MARK: - Map Interactions
    // ------------------------------------------------------- //
    
    func Activate() {
        let PressRecognizer = UITapGestureRecognizer(target: self, action: #selector(PressOnMap))
        // allow users to add interact with the map
        self.mapView.addGestureRecognizer(PressRecognizer)
        isInside = true
    }
    
    func Unactivate() {
        let PressRecognizer = UITapGestureRecognizer(target: self, action: #selector(PressOnMap))
        // unable interaction with the map
        self.mapView.removeGestureRecognizer(PressRecognizer)
        isInside = false
    }
    
    // MARK: - Tag Handling
    // ------------------------------------------------------- //
    
    func putTag(mapView: MGLMapView, id: String, description: String, cordinate: CLLocationCoordinate2D) -> Int {
        
       let marker = MGLPointAnnotation()
        
        switch id {
        case "Dolphin":
            marker.coordinate = cordinate
            marker.title = "Dolphin"
            marker.subtitle = description
            mapView.addAnnotation(marker)
            Unactivate()
        case "Medusa":
            marker.coordinate = cordinate
            marker.title = "Medusa"
            marker.subtitle = description
            mapView.addAnnotation(marker)
            Unactivate()
        case "Diver":
            marker.coordinate = cordinate
            marker.title = "Diver"
            marker.subtitle = description
            mapView.addAnnotation(marker)
            Unactivate()
        case "Position":
            marker.coordinate = cordinate
            marker.title = "Position"
            marker.subtitle = description
            mapView.addAnnotation(marker)
            Unactivate()
        case "SOS":
            marker.coordinate = cordinate
            marker.title = "SOS"
            marker.subtitle = description
            mapView.addAnnotation(marker)
            Unactivate()
        case "Waste":
            marker.coordinate = cordinate
            marker.title = "Waste"
            marker.subtitle = description
            mapView.addAnnotation(marker)
            Unactivate()
        default:
            print("Error in func putTag")
        }
        return marker.hash
    }
    
    func putTagfromServer(mapView: MGLMapView, Tag: Tag) -> Int {
        
        let marker = MGLPointAnnotation()
        
        switch Tag.id {
        case "Dolphin":
            marker.coordinate = CLLocationCoordinate2D(latitude: Tag.x ?? 0, longitude: Tag.y ?? 0)
            marker.title = "Dolphin"
            marker.subtitle = Tag.description
            mapView.addAnnotation(marker)
        case "Medusa":
            marker.coordinate = CLLocationCoordinate2D(latitude: Tag.x ?? 0, longitude: Tag.y ?? 0)
            marker.title = "Medusa"
            marker.subtitle = Tag.description
            mapView.addAnnotation(marker)
        case "Diver":
            marker.coordinate = CLLocationCoordinate2D(latitude: Tag.x ?? 0, longitude: Tag.y ?? 0)
            marker.title = "Diver"
            marker.subtitle = Tag.description
            mapView.addAnnotation(marker)
        case "Position":
            marker.coordinate = CLLocationCoordinate2D(latitude: Tag.x ?? 0, longitude: Tag.y ?? 0)
            marker.title = "Position"
            marker.subtitle = Tag.description
            mapView.addAnnotation(marker)
        case "SOS":
            marker.coordinate = CLLocationCoordinate2D(latitude: Tag.x ?? 0, longitude: Tag.y ?? 0)
            marker.title = "SOS"
            marker.subtitle = Tag.description
            mapView.addAnnotation(marker)
        case "Waste":
            marker.coordinate = CLLocationCoordinate2D(latitude: Tag.x ?? 0, longitude: Tag.y ?? 0)
            marker.title = "Waste"
            marker.subtitle = Tag.description
            mapView.addAnnotation(marker)
        default:
             print("Error in func putTagServer")
        }
        return marker.hash
    }
    
    func putTagsinArray(markerHash: Int, FirebaseID: String) {
        
        print("------------")
        self.Tags_ids.append(FirebaseID)
        self.Tags_hashs.append(markerHash)
        print("putTagsinArray Tags_id = " ,FirebaseID)
        print("putTagsinArray Tags_hash = " ,markerHash)
        print(self.Tags_ids)
        print(self.Tags_hashs)
        print("------------")
    }
    
    func showTags(mapView: MGLMapView) {
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                for tag in snapshot.children.allObjects as! [DataSnapshot] {
                    // getting values
                    let data = tag.value as? NSDictionary
                    let description  = data?["description"] as? String
                    let id  = data?["title"] as? String
                    let x = data?["latitude"] as? Double
                    let y = data?["longitude"] as? Double
                    var markerHash: Int
                    markerHash = self.putTagfromServer(mapView: mapView, Tag: Tag(id: id, description: description, x: x, y: y))
                    print("SHOWTAG TagHash = ", markerHash)
                    self.putTagsinArray(markerHash: markerHash, FirebaseID: tag.key)
                    
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        // THIS IS FOR GETTING DATA WHEN DATA CHANGE IN FIREBASE

        /* ref.observe(DataEventType.value, with: { (snapshot) in
         print(snapshot.childrenCount)
         if snapshot.childrenCount > 0 {
         //print("SHOWOOO")
         for tag in snapshot.children.allObjects as! [DataSnapshot] {
         // getting values
         let data = tag.value as? NSDictionary
         let description  = data?["description"] as? String
         let id  = data?["id"] as? String
         let x = data?["x"] as? Double
         let y = data?["y"] as? Double
         var markerHash: Int
         markerHash = self.putTagfromServer(mapView: mapView, Tag: Tag(id: id, description: description, x: x, y: y))
         print("Puttaginarray SHOWTAG")
         self.putTagsinArray(markerHash: markerHash, FirebaseID: tag.key)
         }*/
    }
    
    func saveTags(id: String, description: String, cordinate: CLLocationCoordinate2D) -> String{
        
        print("SAVE TAGS DEBUT")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        let dateInFormat = dateFormatter.string(from: NSDate() as Date)
        let key = self.ref.childByAutoId().key
        let Tag: [String: Any] = [
            "title": id as Any,
            "description": description as Any,
            "latitude": cordinate.latitude as Any,
            "longitude": cordinate.longitude as Any,
            "time": dateInFormat as Any
        ]
        
        self.ref.child(key!).setValue(Tag)
        return key!
    }
    
    func saveTagAfterChange(Tag: Tag) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        let dateInFormat = dateFormatter.string(from: NSDate() as Date)
        let key = self.ref.childByAutoId().key
        
        let Tag: [String: Any] = [
            "title": Tag.id as Any,
            "description": Tag.description as Any,
            "latitude": Tag.x as Any,
            "longitude": Tag.y as Any,
            "time": dateInFormat as Any
        ]
        
        self.ref.child(key!).setValue(Tag)
        return key!
    }
    
    func removeTag(MarkerHash: Int) {
        var count = 0
        print("Remove HASH + Remove Firebase")
        //hash_firebase = String(hash_firebase)
        while (Tags_hashs[count] != MarkerHash) {
            count = count + 1
        }
        FirebaseManager.shared.removePost(withID: Tags_ids[count])
        Tags_hashs.remove(at: count)
        Tags_ids.remove(at: count)
    }
    
    func ChangeTag(MarkerHash: Int) {
        var count = 0
        var hasDoneWork = false
        print(MarkerHash)
        print(Tags_hashs)
        //hash_firebase = String(hash_firebase)
        while (Tags_hashs[count] != MarkerHash) {
            count = count + 1
        }
        print("ChangeTag count = ", count)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            print("ChangeTag Childrencount = ", snapshot.childrenCount)
            if snapshot.childrenCount > 0 {
                for tag in snapshot.children.allObjects as! [DataSnapshot] {
                    // getting valuess
                    print("Tag_id = ", self.Tags_ids[count])
                    print("Tag_hash = ", self.Tags_hashs[count])
                    if (self.Tags_ids[count] == tag.key && hasDoneWork == false) {
                        self.removeTag(MarkerHash: self.Tags_hashs[count])
                        let data = tag.value as? NSDictionary
                        let id  = data?["title"] as? String
                        let x = data?["latitude"] as? Double
                        let y = data?["longitude"] as? Double
                        var markerHash: Int
                        var FirebaseId: String
                        
                        markerHash = self.putTagfromServer(mapView: self.mapView, Tag: Tag(id: id, description: self.description_tag, x: x, y: y))
                        FirebaseId = self.saveTagAfterChange(Tag: Tag(id: id, description: self.description_tag, x: x, y: y))
                        self.putTagsinArray(markerHash: markerHash, FirebaseID: FirebaseId)
                        hasDoneWork = true
                    }
                }
            }
        }) { (error) in
            print("ERROR")
            print(error.localizedDescription)
        }
        
        //Tags_hashs.remove(at: count)
        //Tags_ids.remove(at: count)
    }
    
    // MARK: - Annotation
    // ------------------------------------------------------- //
    
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
        
        /*let ac = UIAlertController(title: "Add description (optional)", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let Change = UIAlertAction(title: "Change Description", style: .default) { [unowned ac] _ in
            self.description_tag = ac.textFields![0].text!
            self.ChangeTag(MarkerHash: annotation.hash)
            mapView.removeAnnotation(annotation)
        }
        
        let Delete = UIAlertAction(title: "Delete Marker", style: .default) { [unowned ac] _ in
            self.removeTag(MarkerHash: annotation.hash)
            mapView.removeAnnotation(annotation)
        }
        
        ac.addAction(Change)
        ac.addAction(Delete)
        
        present(ac, animated: true)*/
        
    }
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        if annotation is MGLUserLocation && mapView.userLocation != nil {
            return CustomUserLocationAnnotationView()
        }
        return nil
    }
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        
        //var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: "Bouer")
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

        if (isInside == true){
        let PressScreenCoordinates = recognizer.location(in: mapView)
        let PressMapCoordinates = mapView.convert(PressScreenCoordinates, toCoordinateFrom: mapView)
        cordinate = PressMapCoordinates
        Activate()
        let point = mapView.convert(cordinate, toPointTo: mapView)
        let features = mapView.visibleFeatures(at: point, styleLayerIdentifiers: ["water"])
        if (features.description != "[]"){
            
            let ac = UIAlertController(title: "Add description (optional)", message: nil, preferredStyle: .alert)
            ac.addTextField()
            
            let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned ac] _ in
                self.description_tag = ac.textFields![0].text!
                var FirebaseId: String
                var markerHash: Int
                FirebaseId = self.saveTags(id: self.id_tag, description: self.description_tag, cordinate: self.cordinate)
                markerHash = self.putTag(mapView: self.mapView, id: self.id_tag, description: self.description_tag, cordinate: self.cordinate)
                self.putTagsinArray(markerHash: markerHash, FirebaseID: FirebaseId)
                
            }
            ac.addAction(submitAction)
            present(ac, animated: true)
            //self.putTag(mapView: self.mapView, id: self.id_tag, description: self.description_tag, cordinate: self.cordinate)
            //self.saveTags(id: self.id_tag, description: self.description_tag, cordinate: self.cordinate)
        
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
        //showTags(mapView: mapView)
        //actionButton.open(animated: true, completion: nil)
    }
}

// MARK: - Custom Class
// ------------------------------------------------------- //

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
