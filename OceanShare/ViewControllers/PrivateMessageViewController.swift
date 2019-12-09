//
//  PrivateMessageViewController.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 01/11/2019.
//  Copyright © 2019 Joseph Pereniguez. All rights reserved.
//

import UIKit
import Foundation

class PrivateMessageViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        
    }
    
    /**
     - Description - Hide the view.
     */
    @IBAction func closeView(_ sender: Any) {
        let mainTabBarController = storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
        mainTabBarController.selectedViewController = mainTabBarController.viewControllers?[0]
        show(mainTabBarController, sender: self)
    }
    
}
