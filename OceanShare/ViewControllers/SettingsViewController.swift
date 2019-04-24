//
//  SettingsViewController.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 24/04/2019.
//  Copyright © 2019 Joseph Pereniguez. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Actions
    
    @IBAction func handleBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    //Todo: add settings stuff
    
}
