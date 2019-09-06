//
//  SettingsViewController.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 24/04/2019.
//  Copyright © 2019 Joseph Pereniguez. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    let registry = Registry()
    
    // MARK: - Outlets
    
    @IBOutlet weak var degreeSegmentedControl: UISegmentedControl!
    
    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
    }
    
    // MARK: - Setup
    
    func setupView() {
        guard let choosenDegree = UserDefaults.standard.object(forKey: "choosen_degree") else { return }
        print(choosenDegree)
        
        if (choosenDegree as AnyObject) .isEqual("C") {
            degreeSegmentedControl.selectedSegmentIndex = 0
        } else if (choosenDegree as AnyObject) .isEqual("F") {
            degreeSegmentedControl.selectedSegmentIndex = 1
        } else {
            degreeSegmentedControl.selectedSegmentIndex = 0
        }
        /* set localized labels */
        setupLocalizedStrings()
    }
    
    func setupLocalizedStrings() {
        degreeSegmentedControl.setTitle(NSLocalizedString("segmentedDegree1", comment: ""), forSegmentAt: 0)
        degreeSegmentedControl.setTitle(NSLocalizedString("segmentedDegree2", comment: ""), forSegmentAt: 1)
        
    }
    
    // MARK: - Actions
    
    @IBAction func degreeChanged(_ sender: Any) {
        switch degreeSegmentedControl.selectedSegmentIndex
        {
        case 0:
            UserDefaults.standard.set("C", forKey: "choosen_degree")
            UserDefaults.standard.synchronize()
        case 1:
            UserDefaults.standard.set("F", forKey: "choosen_degree")
            UserDefaults.standard.synchronize()
        default:
            break
        }
    }
    
    
    /*@IBAction func handleBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func learnMore(_ sender: Any) {
        guard let url = URL(string: self.registry.websiteUrl) else { return }
        UIApplication.shared.open(url)
        
    }*/
    
    // Todo: add settings stuff
    
}
