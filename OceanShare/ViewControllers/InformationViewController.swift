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

class InformationViewController: UIViewController {
    
    // MARK: - Variables
    
    var effect: UIVisualEffect!
    var currentTappedTextField : UITextField?
    var emailStacked: String?
    var viewStacked: UIView?
    
    // MARK: - Databse
    
    var ref: DatabaseReference!
    let storageRef = FirebaseStorage.Storage().reference()
    var appUser: AppUser? {
        didSet {
            guard let name = appUser?.name else { return }
            guard let emailAddress = appUser?.email else { return }
            guard let shipName = appUser?.ship_name else { return }
            
            userName.text = name
            userEmailAddress.text = emailAddress
            userShipName.text = shipName
            
            self.emailStacked = emailAddress
            
        }
    }
    
    // MARK: - Outlets
    
    // icon outlets
    @IBOutlet weak var nameModifierPic: UIImageView!
    @IBOutlet weak var emailModifierPic: UIImageView!
    @IBOutlet weak var shipModifierPic: UIImageView!
    @IBOutlet weak var passwordModifierPic: UIImageView!
    
    // displayed label oultets
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmailAddress: UILabel!
    @IBOutlet weak var userShipName: UILabel!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        // apply the design stuff to the view
        setupView()
        // keybord handler
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        observeKeyboardNotification()
        // setup the visual effect
        effect = visualEffectView.effect
        visualEffectView.effect = nil
        visualEffectView.isHidden = true
        // get the profile picture and the user name
        self.fetchUserInfo()
        
    }
    
    // MARK: - Setup
    
    func setupView() {
        self.nameModifierPic.image = self.nameModifierPic.image!.withRenderingMode(.alwaysTemplate)
        self.nameModifierPic.tintColor = UIColor(rgb: 0xC5C7D2)
        self.emailModifierPic.image = self.emailModifierPic.image!.withRenderingMode(.alwaysTemplate)
        self.emailModifierPic.tintColor = UIColor(rgb: 0xC5C7D2)
        self.shipModifierPic.image = self.shipModifierPic.image!.withRenderingMode(.alwaysTemplate)
        self.shipModifierPic.tintColor = UIColor(rgb: 0xC5C7D2)
        self.passwordModifierPic.image = self.passwordModifierPic.image!.withRenderingMode(.alwaysTemplate)
        self.passwordModifierPic.tintColor = UIColor(rgb: 0xC5C7D2)
        
    }
    
    // MARK: - Popup Animations
    
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
    
    // open the pop up that handle the ship name changes
    @IBAction func openChangeShip(_ sender: Any) {
        self.viewStacked = shipPopUp
        animateIn(view: shipPopUp)
    }
    
    // MARK: - Setter Actions
    
    @IBAction func acceptChangeName(_ sender: Any) {
        
        let name = nameFieldNameModifier.text
        let currentName = self.appUser?.name
        
        if (name?.isEmpty)! {
            displayMessage(userMessage: "New Name Field is required.")
            return
        }
        
        if currentName == name {
            displayMessage(userMessage: "Please check that the new name you choosed is different from the last one.")
            return
        } else {
            let user = Auth.auth().currentUser
            
            // define the database structure
            let userData: [String: Any] = ["name": name as Any]
            
            // update the user data on the database
            guard let uid = user?.uid else { return }
            self.ref.child("users/\(uid)").updateChildValues(userData)
            self.userName.text = name
            self.animateOut()
        }
        
    }
    
    @IBAction func acceptChangeEmail(_ sender: Any) {
        
        let currentEmail = self.appUser?.email
        let password = self.passwordFieldEmailModifier.text
        let newEmail = self.emailFieldEmailModifier.text
        
        if (password?.isEmpty)! || (newEmail?.isEmpty)! {
            displayMessage(userMessage: "New Email Field and Password Field are required.")
            return
        }
        
        if newEmail == currentEmail {
            displayMessage(userMessage: "New Email should be different than previous one.")
            return
        } else {
                let user = Auth.auth().currentUser
            let credential = EmailAuthProvider.credential(withEmail: currentEmail!, password: password!)
                
                // prompt the user to re-provide their sign-in credentials
                user?.reauthenticateAndRetrieveData(with: credential) { authResult, error in
                    if let error = error {
                        print("X", error)
                        return
                    } else {
                        // update the user email
                        user?.updateEmail(to: newEmail!) { (error) in
                            if error != nil {
                                print("X", error!)
                            } else {
                                // define the database structure
                                let userData: [String: Any] = ["email": newEmail as Any]
                                
                                // update the user data on the database
                                guard let uid = user?.uid else { return }
                                self.ref.child("users/\(uid)").updateChildValues(userData)
                                self.userEmailAddress.text = newEmail
                                print("~ Action Informations: Email updated.")
                                self.animateOut()
                            }
                        }
                    }
                }
        }
    }
    
    @IBAction func acceptChangePassword(_ sender: Any) {
        let currentEmail = self.appUser?.email
        let currentPassword = self.currentPasswordFieldPasswordMofidier.text
        let newPassword = self.passwordFieldPasswordModifier.text
        
        if (currentPassword?.isEmpty)! || (newPassword?.isEmpty)! {
            displayMessage(userMessage: "Current Password Field and New Password Field are required.")
            return
        }
        
        if currentPassword == newPassword {
            displayMessage(userMessage: "New Password should be different than previous one.")
            return
        } else {
            let user = Auth.auth().currentUser
            let credential = EmailAuthProvider.credential(withEmail: currentEmail!, password: currentPassword!)
            
            // prompt the user to re-provide their sign-in credentials
            user?.reauthenticateAndRetrieveData(with: credential) { authResult, error in
                if let error = error {
                    print ("X", error)
                    return
                } else {
                    // update the user password
                    user?.updatePassword(to: newPassword!) { (error) in
                        if error != nil {
                            print("X", error!)
                        } else {
                            print("~ Action Informations: Password updated.")
                            self.animateOut()
                        }
                    }
                }
            }
        }
    }

    @IBAction func acceptChangeShipName(_ sender: Any) {
        let currentShipName = self.appUser?.ship_name!
        let shipName = self.shipFieldShipModifier.text
        
        if (shipName?.isEmpty)! {
            displayMessage(userMessage: "New Ship Name Field is required.")
            return
        }
        
        if shipName == currentShipName {
            displayMessage(userMessage: "New Ship Name Field should be different than previous one.")
            return
        } else {
            let user = Auth.auth().currentUser
            
            // define the database structure
            let userData: [String: Any] = ["ship_name": shipName as Any]
            
            // update the user data on the database
            guard let uid = user?.uid else { return }
            self.ref.child("users/\(uid)").updateChildValues(userData)
            self.userShipName.text = shipName!
            print("~ Action Informations: Ship Name updated.")
            self.animateOut()
        }
    }
    
    // change the view from information view to profile view
    @IBAction func handleBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: false, completion: nil)
        
    }
    
    @IBAction func deleteHandler(_ sender: Any) {
        let alert = UIAlertController(title: "Warning", message: "You are going to delete your account, write your password then tap 'Delete' to confim.", preferredStyle: .alert)
        alert.addTextField { (newShipField : UITextField!) -> Void in
            newShipField.placeholder = "Password"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
            print("~ Action Informations: Cancel Pressed.")
        }))
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { action in
            let password = alert.textFields![0] as UITextField
            self.deleteAccount(password: password.text!)
            print("~ Action Informations: Account is going to be deleted.")
        }))
        
        self.present(alert, animated: true, completion: nil)
        
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
                            let pictureURL = URL(string: "https://image.flaticon.com/icons/png/512/320/320359.png")
                            
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
                        
                    }})
            } else {
                print("X Error User Not Found.")
                return
                
            }
        }
    }
    
    // handle the account deletion
    func deleteAccount(password: String) {
        let user = Auth.auth().currentUser
        let credential = EmailAuthProvider.credential(withEmail: self.emailStacked!, password: password)
        
        // prompt the user to re-provide their sign-in credentials
        user?.reauthenticateAndRetrieveData(with: credential) { authResult, error in
            if let error = error {
                print("X", error)
                
                // define the alter to show in case of the user tapped a wrong password
                let alert = UIAlertController(title: "Wrong Password", message: "Please fill the field with your password if you want to delete your account.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { action in
                    print("~ Action Informations: Close Pressed.")
                }))
                alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { action in
                    print("~ Action Informations: Try Again Pressed.")
                    self.deleteHandler(self)
                }))
                self.present(alert, animated: true, completion: nil)
                
            } else {
                // delete the user data in the Database table
                self.ref.child("users").child(user!.uid).removeValue()
                
                // empty the UserDefault
                let domain = Bundle.main.bundleIdentifier!
                UserDefaults.standard.removePersistentDomain(forName: domain)
                UserDefaults.standard.synchronize()
                print(Array(UserDefaults.standard.dictionaryRepresentation().keys).count)
                
                // delete the user data in the Authentication table
                user?.delete { error in
                    if let error = error {
                        print("X", error)
                    } else {
                        print("~ Action Informations: User Deleted.")
                        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                        self.present(loginViewController, animated: true ,completion: nil)
                    }
                }
                
            }
        }
        
    }
    
    // MARK: - Error Handling
    
    func displayMessage(userMessage:String) -> Void {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Please Fill The Fields Correctly.", message: userMessage, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                print("~ Actions Information: OK Pressed.")
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
            
            self.view.frame = CGRect(x: 0, y: -200, width: self.view.frame.width, height: self.view.frame.height)
            
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
