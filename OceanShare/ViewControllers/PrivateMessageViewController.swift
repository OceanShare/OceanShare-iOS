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
    
    // MARK: - Outlets
    
    @IBOutlet weak var tempMessage: UITextView!
    @IBOutlet weak var tempDismiss: DesignableButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        setupLocalizedStrings()
        
    }
    
    // MARK: - Functions
    
    /**
     - Description - Setup translated labels.
     */
    func setupLocalizedStrings() {
        tempMessage.text = NSLocalizedString("pmTempMessage", comment: "")
        tempDismiss.setTitle(NSLocalizedString("pmTempDismiss", comment: ""), for: .normal)
        
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
