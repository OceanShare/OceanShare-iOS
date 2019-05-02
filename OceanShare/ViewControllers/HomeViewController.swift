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
    
    let point = MGLPointAnnotation()
    let actionButton = JJFloatingActionButton()
    
    var id_tag = 0
    var description_tag = "."
    var x_tag = 0.0
    var y_tag = 0.0
    var cordinate: CLLocationCoordinate2D!
    
    var mapView: MGLMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference().child("Tag")
        // define the MLG map view and the user on this map
        setupMapBox()
        showTags(mapView: mapView)
    }
    
    // MARK : - Setup
    
    func Activate() {
        let PressRecognizer = UITapGestureRecognizer(target: self, action: #selector(PressOnMap))
        print(actionButton.buttonState.rawValue)
        if (actionButton.buttonState.rawValue == 3){
            print("Inside")
            self.mapView.addGestureRecognizer(PressRecognizer)
            
        } else {
            print("outside")
            // mapView.gestureRecognizers?.forEach(mapView.removeGestureRecognizer)
            self.mapView.removeGestureRecognizer(PressRecognizer)
            
        }
    }
    
    func setupMapBox() {
        mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        
        // enable heading tracking mode (arrow will appear)
        mapView.userTrackingMode = .followWithHeading
        // enable the permanent heading indicator which will appear when the tracking mode is not `.followWithHeading`.
        mapView.showsUserHeadingIndicator = true
        // add Marker with click on the map
        //view.addSubview(mapView)
        actionButton.buttonColor = UIColor(rgb: 0x57A1FF)
        
        // list the icon buttons
        actionButton.addItem(title: "Dauphin", image: UIImage(named: "dauphin")?.withRenderingMode(.alwaysTemplate)) { item in
            Helper.showAlert(for: item)
            self.id_tag = 1
            self.description_tag = "Dauphin"
            self.Activate()
        }
        actionButton.addItem(title: "Meduse", image: UIImage(named: "meduse")?.withRenderingMode(.alwaysTemplate)) { item in
            Helper.showAlert(for: item)
            self.id_tag = 2
            self.description_tag = "Meduse"
            self.Activate()
        }
        actionButton.addItem(title: "Plongeur", image: UIImage(named: "plongeur")?.withRenderingMode(.alwaysTemplate)) { item in
            Helper.showAlert(for: item)
            self.id_tag = 3
            self.description_tag = "Plongeur"
            self.Activate()
        }
        actionButton.addItem(title: "Posititon", image: UIImage(named: "Posititon")?.withRenderingMode(.alwaysTemplate)) { item in
            Helper.showAlert(for: item)
            self.id_tag = 4
            self.description_tag = "Posititon"
            self.Activate()
        }
        actionButton.addItem(title: "Warning", image: UIImage(named: "warnongBW")?.withRenderingMode(.alwaysTemplate)) { item in
            Helper.showAlert(for: item)
            self.id_tag = 5
            self.description_tag = "Warning"
            self.Activate()
        }
        actionButton.addItem(title: "Waste", image: UIImage(named: "wasteP")?.withRenderingMode(.alwaysTemplate)) { item in
            Helper.showAlert(for: item)
            self.id_tag = 6
            self.description_tag = "Waste"
            self.Activate()
        }
        view.addSubview(mapView)
        actionButton.display(inViewController: self)
    }
    
    // MARK: - Mapbox Handling
    
    func putTag(mapView: MGLMapView, id: Int, description: String, cordinate: CLLocationCoordinate2D){
        
        print("PutTag Debut")
        
        switch id {
        case 1:
            print("id tag = 1")
            let marker = MGLPointAnnotation()
            marker.coordinate = cordinate
            marker.title = "Dauphin"
            marker.subtitle = description
            mapView.addAnnotation(marker)
        case 2:
            print("id tag = 2")
            let marker = MGLPointAnnotation()
            marker.coordinate = cordinate
            marker.title = "Meduse"
            marker.subtitle = description
            mapView.addAnnotation(marker)
        case 3:
            print("id tag = 3")
            let marker = MGLPointAnnotation()
            marker.coordinate = cordinate
            marker.title = "Plongeur"
            marker.subtitle = description
            mapView.addAnnotation(marker)
        case 4:
            print("id tag = 4")
            let marker = MGLPointAnnotation()
            marker.coordinate = cordinate
            marker.title = "Posititon"
            marker.subtitle = description
            mapView.addAnnotation(marker)
        case 5:
            print("id tag = 5")
            let marker = MGLPointAnnotation()
            marker.coordinate = cordinate
            marker.title = "Warning"
            marker.subtitle = description
            mapView.addAnnotation(marker)
        case 6:
            print("id tag = 6")
            let marker = MGLPointAnnotation()
            marker.coordinate = cordinate
            marker.title = "Waste"
            marker.subtitle = description
            mapView.addAnnotation(marker)
        default:
            print("Error in func putTag")
        }
        print("PutTag Fin")
    }
    
    func putTagfromServer(mapView: MGLMapView, Tag: Tag){
        switch Tag.id {
        case 1:
            print("id tag = 1")
            let marker = MGLPointAnnotation()
            marker.coordinate = CLLocationCoordinate2D(latitude: Tag.x ?? 0, longitude: Tag.y ?? 0)
            marker.title = "Dauphin"
            marker.subtitle = Tag.description
            mapView.addAnnotation(marker)
        case 2:
            print("id tag = 2")
            let marker = MGLPointAnnotation()
            marker.coordinate = CLLocationCoordinate2D(latitude: Tag.x ?? 0, longitude: Tag.y ?? 0)
            marker.title = "Meduse"
            marker.subtitle = Tag.description
            mapView.addAnnotation(marker)
        case 3:
            print("id tag = 3")
            let marker = MGLPointAnnotation()
            marker.coordinate = CLLocationCoordinate2D(latitude: Tag.x ?? 0, longitude: Tag.y ?? 0)
            marker.title = "Plongeur"
            marker.subtitle = Tag.description
            mapView.addAnnotation(marker)
        case 4:
            print("id tag = 4")
            let marker = MGLPointAnnotation()
            marker.coordinate = CLLocationCoordinate2D(latitude: Tag.x ?? 0, longitude: Tag.y ?? 0)
            marker.title = "Posititon"
            marker.subtitle = Tag.description
            mapView.addAnnotation(marker)
        case 5:
            print("id tag = 5")
            let marker = MGLPointAnnotation()
            marker.coordinate = CLLocationCoordinate2D(latitude: Tag.x ?? 0, longitude: Tag.y ?? 0)
            marker.title = "Warning"
            marker.subtitle = Tag.description
            mapView.addAnnotation(marker)
        case 6:
            print("id tag = 6")
            let marker = MGLPointAnnotation()
            marker.coordinate = CLLocationCoordinate2D(latitude: Tag.x ?? 0, longitude: Tag.y ?? 0)
            marker.title = "Waste"
            marker.subtitle = Tag.description
            mapView.addAnnotation(marker)
        default:
            print("Error in func putTag")
        }
    }
    
    func showTags(mapView: MGLMapView) {
        //guard let userId = Auth.auth().currentUser?.uid else { return }
        print(ref!)
        ref.observe(DataEventType.value, with: { (snapshot) in
            print(snapshot.childrenCount)
            if snapshot.childrenCount > 0 {
                print("SHOWOOO")
                
                for tag in snapshot.children.allObjects as! [DataSnapshot] {
                    // getting values
                    let data = tag.value as? NSDictionary
                    let description  = data?["description"] as? String
                    let id  = data?["id"] as? Int
                    let x = data?["x"] as? Double
                    let y = data?["y"] as? Double
                    self.putTagfromServer(mapView: mapView, Tag: Tag(id: id, description: description, x: x, y: y))
                }
                /*
                 guard let data = snapshot.value as? NSDictionary else { return }
                 guard let description = data["description"] as? String else { return }
                 guard let id = data["id"] as? Int else { return }
                 guard let x = data["x"] as? Double else { return }
                 guard let y = data["y"] as? Double else { return }
                 */
                //var tag = Tag(id: id, description: description, x: x, y: y)
                //self.putTag(mapView: mapView, Tag: Tag(id: id, description: description, x: x, y: y))
                print("oui")
            }
            
        })
    }
    
    func saveTags(id: Int, description: String, cordinate: CLLocationCoordinate2D) {
        
        print("SAVE TAGS DEBUT")
        
        let Tag: [String: Any] = [
            "id": id as Any,
            "description": description as Any,
            "x": cordinate.latitude as Any,
            "y": cordinate.longitude as Any
        ]
        
        let key = self.ref.childByAutoId().key
        self.ref.child(key!).setValue(Tag)
        print("SAVE TAGS FIN")
    }
    
    // MARK: - Annotation
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
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
        
        print("MapViewDebut")
        if annotation.title == "Dauphin" {
            var image = UIImage(named: "dauphin")!
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
            test = MGLAnnotationImage(image: image, reuseIdentifier: "Dauphin")
        } else if annotation.title == "Meduse" {
            var image = UIImage(named: "meduse")!
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
            test = MGLAnnotationImage(image: image, reuseIdentifier: "Meduse")
        } else if annotation.title == "Plongeur" {
            var image = UIImage(named: "plongeur")!
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
            test = MGLAnnotationImage(image: image, reuseIdentifier: "Plongeur")
        } else if annotation.title == "Posititon" {
            var image = UIImage(named: "Posititon")!
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
            test = MGLAnnotationImage(image: image, reuseIdentifier: "Posititon")
        } else if annotation.title == "Warning" {
            var image = UIImage(named: "warnongBW")!
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
            test = MGLAnnotationImage(image: image, reuseIdentifier: "Warning")
        } else {
            var image = UIImage(named: "wasteP")!
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
            test = MGLAnnotationImage(image: image, reuseIdentifier: "Waste")
        }
        print("MapViewDebutFin")
        
        return test
    }
    
    /*  func addNewAnnotation(cordinate: CLLocationCoordinate2D) {
     let annotation = MGLPointAnnotation()
     annotation.coordinate = cordinate
     annotation.title = "Dest"
     annotation.subtitle = "01"
     
     mapView.addAnnotation(annotation)
     }
     */
    
    @objc func PressOnMap(_ recognizer: UITapGestureRecognizer) {
        print("PRESSMapDebut")
        let PressScreenCoordinates = recognizer.location(in: mapView)
        let PressMapCoordinates = mapView.convert(PressScreenCoordinates, toCoordinateFrom: mapView)
        cordinate = PressMapCoordinates
        
        self.putTag(mapView: self.mapView, id: self.id_tag, description: self.description_tag, cordinate: self.cordinate)
        self.saveTags(id: self.id_tag, description: self.description_tag, cordinate: self.cordinate)
        //showTags(mapView: mapView)
        Activate()
        print("PRESSMapFin")
        //actionButton.open(animated: true, completion: nil)
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
