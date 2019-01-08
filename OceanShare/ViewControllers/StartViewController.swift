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
    }
    
    // MARK: setup
    
    func setupRadiant() {
        let color1 = UIColor(rgb: 0x57A1FF)
        let color2 = UIColor(rgb: 0x6dd5ed)
        self.StartButton.applyGradient(colours:[color1, color2])
        self.StartButton.clipsToBounds = true
    }
    
}
