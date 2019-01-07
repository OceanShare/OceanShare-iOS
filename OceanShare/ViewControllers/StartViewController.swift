//
//  StartViewController.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 25/12/2018.
//  Copyright © 2018 Joseph Pereniguez. All rights reserved.
//

import UIKit
import Foundation

class StartViewController: UIViewController {
    
    // MARK: outlets
    
    @IBOutlet weak var StartButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRadiant()
        setupShadows()
    }
    
    // MARK: setup
    
    func setupRadiant() {
        let color1 = UIColor(rgb: 0x57A1FF)
        let color2 = UIColor(rgb: 0x6dd5ed)
        self.StartButton.applyGradient(colours:[color1, color2])
        self.StartButton.clipsToBounds = true
    }
    
    func setupShadows() {
        self.StartButton.layer.shadowColor = UIColor.black.cgColor
        self.StartButton.layer.shadowOpacity = 0.3
        self.StartButton.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        self.StartButton.layer.shadowRadius = 5.0
        
        //variable.layer.shadowPath = UIBezierPath(rect: self.GoogleIcon.bounds).cgPath
        //variable.layer.shouldRasterize = true
    }
    
}
