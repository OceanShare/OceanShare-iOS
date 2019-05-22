//
//  SettingsViewController.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 24/04/2019.
//  Copyright © 2019 Joseph Pereniguez. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Actions
    
    @IBAction func handleBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func learnMore(_ sender: Any) {
        //guard let url = URL(string: "http://www.oceanshare.info") else { return }
        guard let url = URL(string: "https://sagotg.github.io/OceanShare/") else { return }
        UIApplication.shared.open(url)
    }
    
    // Todo: add settings stuff
    
}
