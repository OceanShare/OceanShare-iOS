//
//  InformationViewController.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 11/04/2019.
//  Copyright © 2019 Joseph Pereniguez. All rights reserved.
//

import Foundation
import UIKit
import UIKit.UIGestureRecognizerSubclass
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore
import FirebaseStorage
import GoogleSignIn
import SkeletonView
import FirebasePerformance

class InformationViewController: UIViewController {
    
    // MARK: - Variables
    
    var effect: UIVisualEffect!
    var currentTappedTextField : UITextField?
    var emailStacked: String?
    var viewStacked: UIView?
    
    // MARK: - Databse
    
    var ref: DatabaseReference!
    let storageRef = FirebaseStorage.Storage().reference()
    let currentUser = Auth.auth().currentUser
    // get the user information from the AppUser
    var appUser: AppUser? {
        didSet {
            guard let name = appUser?.name else { return }
            guard let emailAddress = appUser?.email else { return }
            guard let shipName = appUser?.ship_name else { return }
            // set the displayed information
            userName.text = name
            userEmailAddress.text = emailAddress
            userShipName.text = shipName
            userPassword.text = "********"
            // set the email stacked used by popups
            self.emailStacked = emailAddress
        }
    }
    
    // MARK: - Outlets
    
    // icon outlets
    @IBOutlet weak var nameModifierPic: UIImageView!
    @IBOutlet weak var emailModifierPic: UIImageView!
    @IBOutlet weak var shipModifierPic: UIImageView!
    @IBOutlet weak var passwordModifierPic: UIImageView!
    
    // container outlets
    @IBOutlet weak var nameContainer: UIView!
    @IBOutlet weak var emailContainer: UIView!
    @IBOutlet weak var shipContainer: UIView!
    @IBOutlet weak var passwordContainer: UIView!
    
    // displayed label oultets
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmailAddress: UILabel!
    @IBOutlet weak var userShipName: UILabel!
    @IBOutlet weak var userPassword: UILabel!
    
    // blur effect view
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    // name pop up outlets
    @IBOutlet var namePopUp: DesignableButton!
    @IBOutlet weak var nameFieldNameModifier: UITextField!
    
    // email pop up outlets
    @IBOutlet var emailPopUp: DesignableButton!
    @IBOutlet weak var emailFieldEmailModifier: UITextField!
    @IBOutlet weak var passwordFieldEmailModifier: UITextField!
    
    // password pop up outlets
    @IBOutlet var passwordPopUp: DesignableButton!
    @IBOutlet weak var currentPasswordFieldPasswordMofidier: UITextField!
    @IBOutlet weak var passwordFieldPasswordModifier: UITextField!
    
    // ship pop up outlets
    @IBOutlet var shipPopUp: DesignableButton!
    @IBOutlet weak var shipFieldShipModifier: UITextField!
    
    // deletion pop up outlets
    @IBOutlet var deletionPopUp: DesignableButton!
    @IBOutlet weak var passwordFieldDeleteModifier: UITextField!
    
    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        self.setupView()
        // keybord handler
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        observeKeyboardNotification()
        self.fetchUserInfo()
    }
    
    // MARK: - Setup
    
    func setupView() {
        self.effect = self.visualEffectView.effect
        self.visualEffectView.effect = nil
        self.visualEffectView.isHidden = true
        self.visualEffectView.alpha = 0.8
        self.setupCustomIcons()
        self.turnOnSkeleton()
    }
    
    func setupCustomIcons() {
        self.nameModifierPic.image = self.nameModifierPic.image!.withRenderingMode(.alwaysTemplate)
        self.nameModifierPic.tintColor = UIColor(rgb: 0xC5C7D2)
        self.emailModifierPic.image = self.emailModifierPic.image!.withRenderingMode(.alwaysTemplate)
        self.emailModifierPic.tintColor = UIColor(rgb: 0xC5C7D2)
        self.shipModifierPic.image = self.shipModifierPic.image!.withRenderingMode(.alwaysTemplate)
        self.shipModifierPic.tintColor = UIColor(rgb: 0xC5C7D2)
        self.passwordModifierPic.image = self.passwordModifierPic.image!.withRenderingMode(.alwaysTemplate)
        self.passwordModifierPic.tintColor = UIColor(rgb: 0xC5C7D2)
    }
    
    // MARK: - Animations
    
    func animateIn(view: UIView) {
        visualEffectView.isHidden = false
        self.view.addSubview(view)
        view.center = self.view.center
        
        view.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        view.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            self.visualEffectView.effect = self.effect
            view.alpha = 1
            view.transform = CGAffineTransform.identity
        }
    }
    
    func animateOut() {
        UIView.animate(withDuration: 0.3, animations: {
            self.viewStacked!.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.viewStacked!.alpha = 0
            self.visualEffectView.effect = nil
        }) { (success:Bool) in
            self.viewStacked!.removeFromSuperview()
                self.visualEffectView.isHidden = true
        }
    }
    
    func turnOnSkeleton() {
        self.nameContainer.isSkeletonable = true
        self.emailContainer.isSkeletonable = true
        self.shipContainer.isSkeletonable = true
        self.passwordContainer.isSkeletonable = true
        self.nameContainer.showAnimatedSkeleton()
        self.emailContainer.showAnimatedSkeleton()
        self.shipContainer.showAnimatedSkeleton()
        self.passwordContainer.showAnimatedSkeleton()
    }
    
    func turnOffSkeleton() {
        self.nameContainer.hideSkeleton()
        self.emailContainer.hideSkeleton()
        self.shipContainer.hideSkeleton()
        self.passwordContainer.hideSkeleton()
    }
    
    // MARK: - Popup Actions
    
    @IBAction func cancelPopUp(_ sender: Any) {
        animateOut()
    }
    
    @IBAction func openChangeName(_ sender: Any) {
        self.viewStacked = namePopUp
        animateIn(view: namePopUp)
    }
    
    @IBAction func openChangeEmail(_ sender: Any) {
        self.viewStacked = emailPopUp
        animateIn(view: emailPopUp)
    }
    
    @IBAction func openChangePassword(_ sender: Any) {
        self.viewStacked = passwordPopUp
        animateIn(view: passwordPopUp)
    }
    
    @IBAction func openChangeShip(_ sender: Any) {
        self.viewStacked = shipPopUp
        animateIn(view: shipPopUp)
    }
    
    @IBAction func deleteHandler(_ sender: Any) {
        self.viewStacked = deletionPopUp
        animateIn(view: deletionPopUp)
    }
    
    // MARK: - Setter Actions
    
    @IBAction func acceptChangeName(_ sender: Any) {
        let name = nameFieldNameModifier.text
        let currentName = self.appUser?.name
        // error checking
        if (name?.isEmpty)! {
            displayMessage(userMessage: "The new name field is required if you want to change yours Matey!")
            return
        }
        if currentName == name {
            displayMessage(userMessage: "The new name should be different from the previous one Matey!")
            return
        } else {
            let trace = Performance.startTrace(name: "changeUserName")
            // define the database structure
            let userData: [String: Any] = ["name": name as Any]
            // update the user data on the database
            guard let uid = self.currentUser?.uid else {
                trace?.stop()
                return
            }
            self.ref.child("users/\(uid)").updateChildValues(userData)
            self.userName.text = name
            self.animateOut()
            print("~ Action Information: Name correclty updated.")
            trace?.stop()
        }
        
    }
    
    @IBAction func acceptChangeEmail(_ sender: Any) {
        let currentEmail = self.emailStacked
        let password = self.passwordFieldEmailModifier.text
        let newEmail = self.emailFieldEmailModifier.text
        // error checking
        if (password?.isEmpty)! || (newEmail?.isEmpty)! {
            displayMessage(userMessage: "The new email field and password field are required if you want to change yours Matey!")
            return
        }
        if newEmail == currentEmail {
            displayMessage(userMessage: "The new email should be different from previous one Matey!")
            return
        } else {
            let trace = Performance.startTrace(name: "changeUserEmail")
            let credential = EmailAuthProvider.credential(withEmail: currentEmail!, password: password!)
            // prompt the user to re-provide their sign-in credentials
            self.currentUser?.reauthenticate(with: credential) { authResult, error in
                if let error = error {
                    print("X", error)
                    self.displayMessage(userMessage: "We are unable to check if you really are the captain.")
                    trace?.stop()
                    return
                } else {
                    // update the user email
                    self.currentUser?.updateEmail(to: newEmail!) { (error) in
                        if error != nil {
                            print("X", error!)
                            self.displayMessage(userMessage: "We are unable to update your email now Captain, please try later.")
                            trace?.stop()
                        } else {
                            // define the database structure
                            let userData: [String: Any] = ["email": newEmail as Any]
                            // update the user data on the database
                            guard let uid = self.currentUser?.uid else {
                                trace?.stop()
                                return
                            }
                            self.ref.child("users/\(uid)").updateChildValues(userData)
                            self.userEmailAddress.text = newEmail
                            self.animateOut()
                            print("~ Action Information: Email correclty updated.")
                            trace?.stop()
                        }
                    }
                }
            }
        }
        
    }
    
    @IBAction func acceptChangePassword(_ sender: Any) {
        let currentEmail = self.emailStacked
        let currentPassword = self.currentPasswordFieldPasswordMofidier.text
        let newPassword = self.passwordFieldPasswordModifier.text
        // error checking
        if (currentPassword?.isEmpty)! || (newPassword?.isEmpty)! {
            displayMessage(userMessage: "The current password field and new password field are required if you want to change yours Matey!")
            return
        }
        if currentPassword == newPassword {
            displayMessage(userMessage: "The new password should be different than previous one Matey!")
            return
        } else {
            let trace = Performance.startTrace(name: "changeUserPassword")
            let credential = EmailAuthProvider.credential(withEmail: currentEmail!, password: currentPassword!)
            // prompt the user to re-provide their sign-in credentials
            self.currentUser?.reauthenticate(with: credential) { authResult, error in
                if let error = error {
                    print ("X", error)
                    self.displayMessage(userMessage: "We are unable to check if you really are the captain.")
                    trace?.stop()
                    return
                } else {
                    // update the user password
                    self.currentUser?.updatePassword(to: newPassword!) { (error) in
                        if error != nil {
                            print("X", error!)
                            self.displayMessage(userMessage: "We are unable to update your password now Captain, please try later.")
                            trace?.stop()
                        } else {
                            self.animateOut()
                            print("~ Action Information: Password  correctly updated.")
                            trace?.stop()
                        }
                    }
                }
            }
        }
        
    }

    @IBAction func acceptChangeShipName(_ sender: Any) {
        let currentShipName = self.appUser?.ship_name!
        let shipName = self.shipFieldShipModifier.text
        // error checking
        if (shipName?.isEmpty)! {
            displayMessage(userMessage: "The new ship name field is required if you want to change yours Matey!")
            return
        }
        if shipName == currentShipName {
            displayMessage(userMessage: "The new ship name field should be different than the previous one Matey!")
            return
        } else {
            let trace = Performance.startTrace(name: "changeShipName")
            // define the database structure
            let userData: [String: Any] = ["ship_name": shipName as Any]
            // update the user data on the database
            guard let uid = self.currentUser?.uid else {
                trace?.stop()
                return
            }
            self.ref.child("users/\(uid)").updateChildValues(userData)
            self.userShipName.text = shipName!
            self.animateOut()
            print("~ Action Informations: Ship name correctly updated.")
            trace?.stop()
        }
    }
    
    @IBAction func acceptDeletion(_ sender: Any) {
        let password = self.passwordFieldDeleteModifier.text
        let email = self.emailStacked
        // error checking
        if (password?.isEmpty)! {
            displayMessage(userMessage: "Yo ho ho, if you really want to leave us, you will need to fill your password field Matey!")
            return
        } else {
            let trace = Performance.startTrace(name: "deleteUser")
            let credential = EmailAuthProvider.credential(withEmail: email!, password: password!)
            // prompt the user to re-provide their sign-in credentials
            self.currentUser?.reauthenticate(with: credential) { authResult, error in
                if let error = error {
                    print("X", error)
                    self.displayMessage(userMessage: "We are unable to check if you really are the captain.")
                    trace?.stop()
                    return
                } else {
                    // delete the user data in the Database table
                    self.ref.child("users").child(self.currentUser!.uid).removeValue()
                    // empty the UserDefault
                    let domain = Bundle.main.bundleIdentifier!
                    UserDefaults.standard.removePersistentDomain(forName: domain)
                    UserDefaults.standard.synchronize()
                    print(Array(UserDefaults.standard.dictionaryRepresentation().keys).count)
                    // delete the user data in the Authentication table
                    self.currentUser?.delete { error in
                        if let error = error {
                            print("X", error)
                            self.displayMessage(userMessage: "We are unable to delete your account now Captain, please try later.")
                            trace?.stop()
                        } else {
                            let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                            self.present(loginViewController, animated: true ,completion: nil)
                            print("~ Action Information: User corretly deleted.")
                            trace?.stop()
                        }
                    }
                }
                
            }
        }
        
    }
    
    // MARK: - Navigation Actions
    
    @IBAction func handleBack(_ sender: Any) {
        let mainTabBarController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
        mainTabBarController.selectedViewController = mainTabBarController.viewControllers?[2]
        self.show(mainTabBarController, sender: self)
    }

    // MARK: - Updater
    
    func fetchUserInfo() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        ref.child("users").child(userId).observeSingleEvent(of: .value) { (snapshot) in
            guard let data = snapshot.value as? NSDictionary else { return }
            guard let userName = data["name"] as? String else { return }
            guard let userEmail = data["email"] as? String else { return }
            guard let userShipName = data["ship_name"] as? String else {
                
                let user = Auth.auth().currentUser
                let defaultShipName = "My Boat"
                let userData: [String: Any] = ["ship_name": defaultShipName as Any]
                // update the user data on the database
                guard let uid = user?.uid else { return }
                self.ref.child("users/\(uid)").updateChildValues(userData)
                self.userShipName.text = defaultShipName
                self.fetchUserInfo()
                return
                
            }
            
            let user = Auth.auth().currentUser
            let trace = Performance.startTrace(name: "fetchUserPictureFromProfileView")
            
            if let user = user {
                _ = Storage.storage().reference().child("profile_pictures").child("\(String(describing: user.uid)).png").downloadURL(completion: { (url, error) in
                    if error != nil {
                        // check if the user has a network profile picture
                        if let userPicture = data["picture"] as? String {
                            let pictureURL = URL(string: userPicture)
                            let pictureData = NSData(contentsOf: pictureURL!)
                            let finalPicture = UIImage(data: pictureData! as Data)
                            
                            self.appUser = AppUser(name: userName, uid: userId, email: userEmail, picture: finalPicture, ship_name: userShipName)
                        } else {
                            // set a default avatar
                            let pictureURL = URL(string: "https://scontent-lax3-2.xx.fbcdn.net/v/t1.0-1/p480x480/29187034_1467064540082381_56763327166021632_n.jpg?_nc_cat=107&_nc_ht=scontent-lax3-2.xx&oh=7c2e6e423e8bd35727d754d1c47059d6&oe=5D33AACC")
                            // todo, find a better default user profile picture
                            let pictureData = NSData(contentsOf: pictureURL!)
                            let finalPicture = UIImage(data: pictureData! as Data)
                            
                            self.appUser = AppUser(name: userName, uid: userId, email: userEmail, picture: finalPicture, ship_name: userShipName)
                        }
                    } else {
                        // set the custom profile picture if the user has one
                        let pictureData = NSData(contentsOf: url!)
                        let finalPicture = UIImage(data: pictureData! as Data)
                        
                        self.appUser = AppUser(name: userName, uid: userId, email: userEmail, picture: finalPicture, ship_name: userShipName)
                    }
                    self.turnOffSkeleton()
                })
            } else {
                print("X Error User Not Found.")
                trace?.stop()
                return
            }
            trace?.stop()
        }
    }
    
    // MARK: - Error Handling
    
    func displayMessage(userMessage:String) -> Void {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Blimey!", message: userMessage, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                print("~ Action Information: OK pressed.")
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion:nil)
        }
    }
    
    // MARK: - Keyboard Handling
    
    fileprivate func observeKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardShow() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.frame = CGRect(x: 0, y: -150, width: self.view.frame.width, height: self.view.frame.height)
            
        }, completion: nil)
    }
    
    @objc func keyboardHide() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            
        }, completion: nil)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        currentTappedTextField = textField
        return true
    }
    
}
