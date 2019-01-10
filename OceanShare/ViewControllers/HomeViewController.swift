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
import JJFloatingActionButton

class HomeViewController: UIViewController, MGLMapViewDelegate {
    
    // MARK: definitions
    
    let point = MGLPointAnnotation()
    fileprivate let actionButton = JJFloatingActionButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        
        // Enable heading tracking mode so that the arrow will appear.
        mapView.userTrackingMode = .followWithHeading
        
        // Enable the permanent heading indicator, which will appear when the tracking mode is not `.followWithHeading`.
        mapView.showsUserHeadingIndicator = true
        
        view.addSubview(mapView)
        
        // Declare the marker and set its coordinates, title, and subtitle.
        let hello = MGLPointAnnotation()
        hello.coordinate = CLLocationCoordinate2D(latitude: 40.7326808, longitude: -73.9843407)
        hello.title = "Dauphins"
        hello.subtitle = "Présence de dauphins dans cette zone."
        
        mapView.addAnnotation(hello) // Add marker `hello` to the map.
        
        // icon menu implementation
        actionButton.addItem(title: "Immigrants", image: UIImage(named: "lifesaver")?.withRenderingMode(.alwaysTemplate)) { item in
            Helper.showAlert(for: item)
            
            let Bouer = MGLPointAnnotation()
            Bouer.coordinate = CLLocationCoordinate2D(latitude: 26.212596, longitude: 50.611647)
            Bouer.title = "Bouer"
            Bouer.subtitle = "Présence de boué dans cette zone."
            
            mapView.addAnnotation(Bouer)
        }
        actionButton.addItem(title: "Strom", image: UIImage(named: "cloud")?.withRenderingMode(.alwaysTemplate)) { item in
            Helper.showAlert(for: item)
            
            let storm = MGLPointAnnotation()
            storm.coordinate = CLLocationCoordinate2D(latitude: 26.217606, longitude: 50.611365)
            storm.title = "Storm"
            storm.subtitle = "Présence de storm dans cette zone."
            
            mapView.addAnnotation(storm)
        }
        actionButton.addItem(title: "Destination", image: UIImage(named: "define_location")?.withRenderingMode(.alwaysTemplate)) { item in
            Helper.showAlert(for: item)
            
            let dest = MGLPointAnnotation()
            dest.coordinate = CLLocationCoordinate2D(latitude: 26.218915, longitude: 50.605185)
            dest.title = "Destination"
            dest.subtitle = "Oui"
            mapView.addAnnotation(dest)
        }
        actionButton.display(inViewController: self)
    }
    
    // MARK : Functions
    
    // Allow callout view to appear when an annotation is tapped.
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        // Substitute our custom view for the user location annotation. This custom view is defined below.
        if annotation is MGLUserLocation && mapView.userLocation != nil {
            return CustomUserLocationAnnotationView()
        }
        return nil
    }
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        // Try to reuse the existing ‘pisa’ annotation image, if it exists.
     //   var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: "Bouer")
        
        var test = MGLAnnotationImage()
        
     //   if test == nil {
            print("TEST")
            if annotation.title == "Bouer" {
                var image = UIImage(named: "lifesaver")!
                image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
                test = MGLAnnotationImage(image: image, reuseIdentifier: "Bouer")
            }
            else if annotation.title == "Storm" {
                var image = UIImage(named: "cloud")!
                image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
                test = MGLAnnotationImage(image: image, reuseIdentifier: "storm")
            }
            else {
                var image = UIImage(named: "define_location")!
                image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
                test = MGLAnnotationImage(image: image, reuseIdentifier: "dest")
        }
      /*      var image = UIImage(named: "lifesaver")!
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
            annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "Bouer") */
       // }
        
        return test
    }
}

// Create a subclass of MGLUserLocationAnnotationView.
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
        
        // Check whether we have the user’s location yet.
        if CLLocationCoordinate2DIsValid(userLocation!.coordinate) {
            setupLayers()
            updateHeading()
        }
    }
    
    private func updateHeading() {
        // Show the heading arrow, if the heading of the user is available.
        if let heading = userLocation!.heading?.trueHeading {
            arrow.isHidden = false
            
            // Get the difference between the map’s current direction and the user’s heading, then convert it from degrees to radians.
            let rotation: CGFloat = -MGLRadiansFromDegrees(mapView!.direction - heading)
            
            // If the difference would be perceptible, rotate the arrow.
            if abs(rotation) > 0.01 {
                // Disable implicit animations of this rotation, which reduces lag between changes.
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
