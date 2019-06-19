//
//  StartViewController.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 25/12/2018.
//  Copyright © 2018 Joseph Pereniguez. All rights reserved.
//

import UIKit
import Foundation
import Crashlytics
import Fabric

class StartViewController: UIViewController, UIPageViewControllerDelegate {
    
    // MARK: - Variables
    
    //let parentView = RootViewController()
    
    // MARK: - outlets
    
    @IBOutlet weak var StartButton: UIButton!
    @IBOutlet weak var CrashButton: UIButton!
    
    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // apply the design stuff to the view
        setupRadiant()
        //Fabric.sharedSDK().debug = true
        CrashButton.isHidden = true
    }
    
    // MARK: - Setup
    
    func setupRadiant() {
        let color1 = UIColor(rgb: 0x57A1FF)
        let color2 = UIColor(rgb: 0x6dd5ed)
        self.StartButton.applyGradient(colours:[color1, color2], corner:27.5)
    }
    
    @IBAction func didPressCrash(_ sender: Any) {
        print("Crash Button Pressed!")
        Crashlytics.sharedInstance().crash()
    }
    
    
}
