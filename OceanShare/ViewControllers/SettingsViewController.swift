//
//  SettingsViewController.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 24/04/2019.
//  Copyright © 2019 Joseph Pereniguez. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseFunctions
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore
import FirebaseStorage
import FirebasePerformance

class SettingsViewController: UIViewController {
    
    let registry = Registry()
    
    // MARK: - Variables
    
    /* default values */
    let ghostModeDefault = true
    let showPictureDefault = false
    let boatIdDefault = 1
    let isUserActiveDefault = true

    /* firebase */
    var userRef: DatabaseReference!
    
    // MARK: - Outlets
    
    @IBOutlet weak var degreeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var viewTitleLabel: UILabel!
    @IBOutlet weak var temperatureDisplayTitle: UILabel!
    @IBOutlet weak var showProfileSwitch: UISwitch!
    @IBOutlet weak var ghostModeSwitch: UISwitch!
    @IBOutlet weak var sailingBoatView: DesignableView!
    @IBOutlet weak var gondolaView: DesignableButton!
    @IBOutlet weak var miniYachtView: DesignableButton!
    @IBOutlet weak var yachtView: DesignableButton!
    @IBOutlet weak var sailingBoatButton: UIButton!
    @IBOutlet weak var gondolaButton: UIButton!
    @IBOutlet weak var miniYachtButton: UIButton!
    @IBOutlet weak var yachtButton: UIButton!
    
    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userRef = Database.database().reference().child("users")
        
        fetchSettings()
        setupView()

    }
    
    // MARK: - Setup
    
    /*
     * Setup the state button and call the function that setup localized strings
     */
    func setupView() {
        guard let choosenDegree = UserDefaults.standard.object(forKey: "choosen_degree") else { return }
        
        if (choosenDegree as AnyObject) .isEqual("C") {
            degreeSegmentedControl.selectedSegmentIndex = 0
        } else if (choosenDegree as AnyObject) .isEqual("F") {
            degreeSegmentedControl.selectedSegmentIndex = 1
        } else {
            degreeSegmentedControl.selectedSegmentIndex = 0
        }
        
        setupLocalizedStrings()
    }
    
    /*
     * Setup the preferences from the user database.
     */
    func setupPreferences(ghostMode: Bool, showPicture: Bool, boatId: Int) {
        if (ghostMode == true) {
            ghostModeSwitch.isOn = true
        } else {
            ghostModeSwitch.isOn = false
        }
        
        if (showPicture == true) {
            showProfileSwitch.isOn = true
        } else {
            showProfileSwitch.isOn = false
        }
        
        switch boatId {
        case 1:
            sailingBoatView.isHidden = false
            sailingBoatButton.isEnabled = false
            
        case 2:
            gondolaView.isHidden = false
            gondolaButton.isEnabled = false
        case 3:
            miniYachtView.isHidden = false
            miniYachtButton.isEnabled = false
        case 4:
            yachtView.isHidden = false
            yachtButton.isEnabled = false
        default:
            sailingBoatView.isHidden = false
            sailingBoatButton.isEnabled = false
        }
    }
    
    /*
     * Setup the localized strings.
     */
    func setupLocalizedStrings() {
        viewTitleLabel.text = NSLocalizedString("settingViewTitle", comment: "")
        temperatureDisplayTitle.text = NSLocalizedString("settingTemperatureTitle", comment: "")
        degreeSegmentedControl.setTitle(NSLocalizedString("segmentedDegree1", comment: ""), forSegmentAt: 0)
        degreeSegmentedControl.setTitle(NSLocalizedString("segmentedDegree2", comment: ""), forSegmentAt: 1)
        
    }
    
    // MARK: - Functions
    
    /*
     * Reload the view to get the user preferences from the database.
     */
    func fetchSettings() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        userRef.child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot == snapshot {
                guard let data = snapshot.value as? NSDictionary else { return }
                guard let preferences = data["preferences"] as? [String : AnyObject] else {
                    
                    let userPreferencesData: [String: Any] = [
                        "ghost_mode": self.ghostModeDefault as Bool,
                        "show_picture": self.showPictureDefault as Bool,
                        "boatId": self.boatIdDefault as Int,
                        "user_active": self.isUserActiveDefault as Bool
                        ]
                    
                    self.userRef.child("\(userId)/preferences").updateChildValues(userPreferencesData)
                    self.fetchSettings()
                    return
                }
            
                guard let ghostMode = preferences["ghost_mode"] as? Bool else { return }
                guard let showPicture = preferences["show_picture"] as? Bool else { return }
                guard let boatId = preferences["boatId"] as? Int else { return }
            
                self.setupPreferences(ghostMode: ghostMode, showPicture: showPicture, boatId: boatId)
            }
        })
        
    }
    
    /*
     * Change the user boatId to determine the user avatar and the boat type.
     */
    func updateBoatId(newBoatId: Int) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        userRef.child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot == snapshot {
                guard let data = snapshot.value as? NSDictionary else { return }
                guard let preferences = data["preferences"] as? [String : AnyObject] else { return }
            
                guard let boatId = preferences["boatId"] as? Int else { return }
            
                if (boatId != newBoatId) {
                    let data: [String: Any] = ["boatId": newBoatId as Int]
                    self.userRef.child("\(userId)/preferences").updateChildValues(data)
                    self.fetchSettings()
                    
                } else {
                    print("Error in function updateBoatId(): boatId is already equal to \(newBoatId).")
                    return
                    
                }
            }
        })
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
        guard let userId = Auth.auth().currentUser?.uid else { return }
               
               userRef.child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
                   if snapshot == snapshot {
                       guard let data = snapshot.value as? NSDictionary else { return }
                       guard let preferences = data["preferences"] as? [String : AnyObject] else { return }
                   
                       guard let ghostMode = preferences["ghost_mode"] as? Bool else { return }
                   
                    if (self.ghostModeSwitch.isOn == true) {
                           let data: [String: Any] = ["ghost_mode": false as Bool]
                           self.userRef.child("\(userId)/preferences").updateChildValues(data)
                           self.fetchSettings()
                           
                       } else {
                           let data: [String: Any] = ["ghost_mode": true as Bool]
                           self.userRef.child("\(userId)/preferences").updateChildValues(data)
                           self.fetchSettings()
                           
                       }
                   }
               })
    }
    
    @IBAction func sailingBoatActivate(_ sender: Any) {
        updateBoatId(newBoatId: 1)
    }
    
    @IBAction func gondolaActivate(_ sender: Any) {
        updateBoatId(newBoatId: 2)
    }
    
    @IBAction func miniYachtActivate(_ sender: Any) {
        updateBoatId(newBoatId: 3)
    }
    
    @IBAction func yachtActivate(_ sender: Any) {
        updateBoatId(newBoatId: 4)
    }
    
}
