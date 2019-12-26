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
    var userRef: DatabaseReference!
    let registry = Registry()
    
    // MARK: - Outlets
    
    /* objects */
    @IBOutlet weak var degreeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var showProfileSwitch: UISwitch!
    @IBOutlet weak var ghostModeSwitch: UISwitch!
    @IBOutlet weak var logoutButton: DesignableButton!
    
    /* localized strings */
    @IBOutlet weak var viewTitleLabel: UILabel!
    @IBOutlet weak var temperatureDisplayTitle: UILabel!
    @IBOutlet weak var showProfileLabel: UILabel!
    @IBOutlet weak var showProfileTextView: UITextView!
    @IBOutlet weak var ghostModeLabel: UILabel!
    @IBOutlet weak var ghostModeTextView: UITextView!
    @IBOutlet weak var boatTypeLabel: UILabel!
    
    /* boat type filter */
    @IBOutlet weak var sailingBoatView: DesignableView!
    @IBOutlet weak var gondolaView: DesignableButton!
    @IBOutlet weak var miniYachtView: DesignableButton!
    @IBOutlet weak var yachtView: DesignableButton!
    
    /* boat type avatar */
    @IBOutlet weak var sailingBoatButton: UIButton!
    @IBOutlet weak var gondolaButton: UIButton!
    @IBOutlet weak var miniYachtButton: UIButton!
    @IBOutlet weak var yachtButton: UIButton!
    
    // MARK: - View Manager
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        userRef = Database.database().reference().child("users")
        fetchSettings()
        setupView()

    }
    
    // MARK: - Setup

    /**
     - Description - Setup the state button and call the function that setup localized strings.
     */
    func setupView() {
        if Defaults.getUserDetails().isCelsius == true {
            degreeSegmentedControl.selectedSegmentIndex = 0
        } else {
            degreeSegmentedControl.selectedSegmentIndex = 1
        }
        
        setupLocalizedStrings()
    }
    
    /**
     - Description - Setup the preferences from the user database.
     - Inputs - ghostMode `Bool` & showPicture `Bool` & boatId `Int`
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
            
            gondolaView.isHidden = true
            gondolaButton.isEnabled = true
            miniYachtView.isHidden = true
            miniYachtButton.isEnabled = true
            yachtView.isHidden = true
            yachtButton.isEnabled = true
        case 2:
            gondolaView.isHidden = false
            gondolaButton.isEnabled = false
            
            sailingBoatView.isHidden = true
            sailingBoatButton.isEnabled = true
            miniYachtView.isHidden = true
            miniYachtButton.isEnabled = true
            yachtView.isHidden = true
            yachtButton.isEnabled = true
        case 3:
            miniYachtView.isHidden = false
            miniYachtButton.isEnabled = false
            
            gondolaView.isHidden = true
            gondolaButton.isEnabled = true
            gondolaView.isHidden = true
            gondolaButton.isEnabled = true
            yachtView.isHidden = true
            yachtButton.isEnabled = true
        case 4:
            yachtView.isHidden = false
            yachtButton.isEnabled = false
            
            sailingBoatView.isHidden = true
            sailingBoatButton.isEnabled = true
            gondolaView.isHidden = true
            gondolaButton.isEnabled = true
            miniYachtView.isHidden = true
            miniYachtButton.isEnabled = true
        default:
            print("Error in function setupPreferences: boatId not found.")
            return
            
        }
    }
    
    /**
     - Description - Setup the localized strings.
     */
    func setupLocalizedStrings() {
        viewTitleLabel.text = NSLocalizedString("settingViewTitle", comment: "")
        temperatureDisplayTitle.text = NSLocalizedString("settingTemperatureTitle", comment: "")
        degreeSegmentedControl.setTitle(NSLocalizedString("segmentedDegree1", comment: ""), forSegmentAt: 0)
        degreeSegmentedControl.setTitle(NSLocalizedString("segmentedDegree2", comment: ""), forSegmentAt: 1)
        showProfileLabel.text = NSLocalizedString("showProfileLabel", comment: "")
        showProfileTextView.text = NSLocalizedString("showProfileTextView", comment: "")
        ghostModeLabel.text = NSLocalizedString("ghostModeLabel", comment: "")
        ghostModeTextView.text = NSLocalizedString("ghostModeTextView", comment: "")
        boatTypeLabel.text = NSLocalizedString("boatTypeLabel", comment: "")
        logoutButton.setTitle(NSLocalizedString("profileLogoutLabel", comment: ""), for: .normal)
    }
    
    // MARK: - Functions
    
    /**
     - Description - Reload the view to get the user preferences from the database.
     */
    func fetchSettings() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        userRef.child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot == snapshot {
                guard let data = snapshot.value as? NSDictionary else { return }
                guard let preferences = data["preferences"] as? [String : AnyObject] else { return }
                guard let ghostMode = preferences["ghost_mode"] as? Bool else { return }
                guard let showPicture = preferences["show_picture"] as? Bool else { return }
                guard let boatId = preferences["boatId"] as? Int else { return }
            
                self.setupPreferences(ghostMode: ghostMode, showPicture: showPicture, boatId: boatId)
            }
        })
        
    }

    /**
     - Description - Change the user boatId to determine the user avatar and the boat type.
     - Inputs - newBoatId `Int`
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
    
    /**
     - Description - Log out the user from the app.
     */
    @IBAction func handleLogout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            if Auth.auth().currentUser == nil {
                // Remove User Session from device
                Defaults.clearUserData()
                let signInPage = self.storyboard!.instantiateViewController(withIdentifier: "LoginViewController")
                let appDelegate = UIApplication.shared.delegate
                appDelegate?.window??.rootViewController = signInPage
                print("-> User has correctly logged out.")
                
            }
        } catch let signOutError as NSError {
            print ("X Error signing out: %@", signOutError)
            
        }
    }

    /**
      - Description - Go back to the profileViewController.
     */
    @IBAction func handleBack(_ sender: Any) {
        let mainTabBarController = storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
        mainTabBarController.selectedViewController = mainTabBarController.viewControllers?[2]
        show(mainTabBarController, sender: self)
        
    }
    
    /**
      - Description - Update local memory to setup temperature type choosen by users.
     */
    @IBAction func degreeChanged(_ sender: Any) {
        switch degreeSegmentedControl.selectedSegmentIndex
        {
        case 0:
            Defaults.save(Defaults.getUserDetails().uid, name: Defaults.getUserDetails().name, email: Defaults.getUserDetails().email, picture: Defaults.getUserDetails().picture, shipName: Defaults.getUserDetails().shipName, boatId: Defaults.getUserDetails().boatId, ghostMode: Defaults.getUserDetails().ghostMode, showPicture: Defaults.getUserDetails().showPicture, isEmail: Defaults.getUserDetails().isEmail, isCelsius: true, subEnd: Defaults.getUserDetails().subEnd)
        case 1:
            Defaults.save(Defaults.getUserDetails().uid, name: Defaults.getUserDetails().name, email: Defaults.getUserDetails().email, picture: Defaults.getUserDetails().picture, shipName: Defaults.getUserDetails().shipName, boatId: Defaults.getUserDetails().boatId, ghostMode: Defaults.getUserDetails().ghostMode, showPicture: Defaults.getUserDetails().showPicture, isEmail: Defaults.getUserDetails().isEmail, isCelsius: false, subEnd: Defaults.getUserDetails().subEnd)
        default:
            break
        }
    }
    
    /**
      - Description - Activate or desactivate the possibility to display user's profile picture on the map. When showProfileSwitch is off, the boat type avatar is shown on the map instead of profile picture.
     */
    @IBAction func showProfilePicture(_ sender: Any) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
               
        userRef.child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
           if snapshot == snapshot {
                if (self.showProfileSwitch.isOn == true) {
                       let data: [String: Any] = ["show_picture": true as Bool]
                       self.userRef.child("\(userId)/preferences").updateChildValues(data)
                       self.fetchSettings()
                       
                   } else {
                       let data: [String: Any] = ["show_picture": false as Bool]
                       self.userRef.child("\(userId)/preferences").updateChildValues(data)
                       self.fetchSettings()
                       
                   }
               }
        })
    }
    
    /**
      - Description - When ghost mode is active, the user is completly invisible on the map and other users can't see its location.
     */
    @IBAction func ghostMode(_ sender: Any) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
               
        userRef.child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
           if snapshot == snapshot {
                if (self.ghostModeSwitch.isOn == false) {
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

    /**
      - Description - Select the sailing boat as boat type and user avatar.
     */
    @IBAction func sailingBoatActivate(_ sender: Any) {
        updateBoatId(newBoatId: 1)
    }
    
    /**
     - Description - Select the gondola as boat type and user avatar.
    */
    @IBAction func gondolaActivate(_ sender: Any) {
        updateBoatId(newBoatId: 2)
    }
    
    /**
     - Description - Select the mini yacht as boat type and user avatar.
    */
    @IBAction func miniYachtActivate(_ sender: Any) {
        updateBoatId(newBoatId: 3)
    }
    
    /**
     - Description - Select the yacht as boat type and user avatar.
    */
    @IBAction func yachtActivate(_ sender: Any) {
        updateBoatId(newBoatId: 4)
    }
    
}
