//
//  MainTabBarController.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 31/12/2018.
//  Copyright © 2018 Joseph Pereniguez. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    @IBOutlet weak var mainBar: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        
    }

    func setupView() {
        /* set localized labels */
        setupLocalizedStrings()
    }
    
    func setupLocalizedStrings() {
        // TODO
    }
    
}
