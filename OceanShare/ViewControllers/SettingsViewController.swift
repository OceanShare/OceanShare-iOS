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
    @IBOutlet weak var viewTitleLabel: UILabel!
    @IBOutlet weak var temperatureDisplayTitle: UILabel!
    @IBOutlet weak var showProfileSwitch: UISwitch!
    @IBOutlet weak var ghostModeSwitch: UISwitch!
    
    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
    }
    
    // MARK: - Setup
    
    func setupView() {
        guard let choosenDegree = UserDefaults.standard.object(forKey: "choosen_degree") else { return }
        guard let isGhostModeActive = UserDefaults.standard.object(forKey: "ghost_mode") else { return }
        guard let isPPAllowed = UserDefaults.standard.object(forKey: "show_pp") else { return }
        
        if (choosenDegree as AnyObject) .isEqual("C") {
            degreeSegmentedControl.selectedSegmentIndex = 0
        } else if (choosenDegree as AnyObject) .isEqual("F") {
            degreeSegmentedControl.selectedSegmentIndex = 1
        } else {
            degreeSegmentedControl.selectedSegmentIndex = 0
        }
        
        if (isGhostModeActive as AnyObject) .isEqual(1) {
            ghostModeSwitch.isOn = true
        } else if (isGhostModeActive as AnyObject) .isEqual(0) {
            ghostModeSwitch.isOn = false
        } else {
            ghostModeSwitch.isOn = true
        }
        
        if (isPPAllowed as AnyObject) .isEqual(0) {
            showProfileSwitch.isOn = false
        } else if (isPPAllowed as AnyObject) .isEqual(1) {
            showProfileSwitch.isOn = true
        } else {
            showProfileSwitch.isOn = false
        }
        
        /* set localized labels */
        setupLocalizedStrings()
    }
    
    func setupLocalizedStrings() {
        viewTitleLabel.text = NSLocalizedString("settingViewTitle", comment: "")
        temperatureDisplayTitle.text = NSLocalizedString("settingTemperatureTitle", comment: "")
        degreeSegmentedControl.setTitle(NSLocalizedString("segmentedDegree1", comment: ""), forSegmentAt: 0)
        degreeSegmentedControl.setTitle(NSLocalizedString("segmentedDegree2", comment: ""), forSegmentAt: 1)
        
    }
    
    // MARK: - Actions
    
    @IBAction func handleBack(_ sender: Any) {
        let mainTabBarController = storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
        mainTabBarController.selectedViewController = mainTabBarController.viewControllers?[2]
        show(mainTabBarController, sender: self)
        
    }
    
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
    
    @IBAction func showProfilePicture(_ sender: Any) {
        
    }
    
    @IBAction func ghostMode(_ sender: Any) {
        
    }
    
    @IBAction func sailingBoatActivate(_ sender: Any) {
        
    }
    
    @IBAction func gondolaActivate(_ sender: Any) {
        
    }
    
    @IBAction func miniYachtActivate(_ sender: Any) {
        
    }
    
    @IBAction func yachtActivate(_ sender: Any) {
        
    }
    
}
