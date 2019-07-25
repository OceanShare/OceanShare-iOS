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
    
    let registry = Registry()
    
    // MARK: - Outlets
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var crashButton: UIButton!
    
    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // apply the design stuff to the view
        setupView()
        //Fabric.sharedSDK().debug = true
        
    }
    
    // MARK: - Setup
    
    func setupView() {
        let color1 = registry.customClearBlue
        let color2 = registry.customWhiteBlue
        startButton.applyGradient(colours:[color1, color2], corner:27.5)
        crashButton.isHidden = true
    }
    
    // MARK: - Actions
    
    @IBAction func didPressCrash(_ sender: Any) {
        print("Crash Button Pressed!")
        Crashlytics.sharedInstance().crash()
    }
    
}
