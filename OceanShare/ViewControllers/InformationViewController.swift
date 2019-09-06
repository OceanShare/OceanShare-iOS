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
    let storageRef = Storage.storage().reference()
    let currentUser = Auth.auth().currentUser
    let registry = Registry()
    
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
    
    /* view */
    @IBOutlet weak var viewTitleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var shipNameLabel: UILabel!
    @IBOutlet weak var legalDescription: UITextView!
    @IBOutlet weak var deleteButton: UIButton!
    
    /* icon outlets */
    @IBOutlet weak var nameModifierPic: UIImageView!
    @IBOutlet weak var emailModifierPic: UIImageView!
    @IBOutlet weak var shipModifierPic: UIImageView!
    @IBOutlet weak var passwordModifierPic: UIImageView!
    
    /* container outlets */
    @IBOutlet weak var nameContainer: UIView!
    @IBOutlet weak var emailContainer: UIView!
    @IBOutlet weak var shipContainer: UIView!
    @IBOutlet weak var passwordContainer: UIView!
    
    /* displayed label oultets */
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmailAddress: UILabel!
    @IBOutlet weak var userShipName: UILabel!
    @IBOutlet weak var userPassword: UILabel!
    
    /* blur effect view */
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    /* name pop up outlets */
    @IBOutlet var namePopUp: DesignableButton!
    @IBOutlet weak var namePopUpDescription: UITextView!
    @IBOutlet weak var nameFieldNameModifier: UITextField!
    @IBOutlet weak var namePopUpAccept: DesignableButton!
    @IBOutlet weak var namePopUpCancel: DesignableButton!
    
    /* email pop up outlets */
    @IBOutlet var emailPopUp: DesignableButton!
    @IBOutlet weak var emailPopUpDescription: UITextView!
    @IBOutlet weak var emailFieldEmailModifier: UITextField!
    @IBOutlet weak var passwordFieldEmailModifier: UITextField!
    @IBOutlet weak var emailPopUpAccept: DesignableButton!
    @IBOutlet weak var emailPopUpCancel: DesignableButton!
    
    /* password pop up outlets */
    @IBOutlet var passwordPopUp: DesignableButton!
    @IBOutlet weak var passwordPopUpDescription: UITextView!
    @IBOutlet weak var currentPasswordFieldPasswordMofidier: UITextField!
    @IBOutlet weak var passwordFieldPasswordModifier: UITextField!
    @IBOutlet weak var passwordPopUpAccept: DesignableButton!
    @IBOutlet weak var passwordPopUpCancel: DesignableButton!
    
    /* ship pop up outlets */
    @IBOutlet var shipPopUp: DesignableButton!
    @IBOutlet weak var shipPopUpDescripiton: UITextView!
    @IBOutlet weak var shipFieldShipModifier: UITextField!
    @IBOutlet weak var shipPopUpAccept: DesignableButton!
    @IBOutlet weak var shipPopUpCancel: DesignableButton!
    
    /* deletion pop up outlets */
    @IBOutlet var deletionPopUp: DesignableButton!
    @IBOutlet weak var deletePopUpDescription: UITextView!
    @IBOutlet weak var passwordFieldDeleteModifier: UITextField!
    @IBOutlet weak var deletePopUpAccept: DesignableButton!
    @IBOutlet weak var deletePopUpCancel: DesignableButton!
    
    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        setupView()
        fetchUserInfo()
        
    }
    
    // MARK: - Setup
    
    func setupView() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:))))
        observeKeyboardNotification()
        effect = visualEffectView.effect
        visualEffectView.effect = nil
        visualEffectView.isHidden = true
        visualEffectView.alpha = 0.8
        setupCustomIcons()
        turnOnSkeleton()
        setupLocalizedStrings()
        
    }
    
    func setupLocalizedStrings() {
        viewTitleLabel.text = NSLocalizedString("informationTitle", comment: "")
        nameLabel.text = NSLocalizedString("informationNameTitle", comment: "")
        emailLabel.text = NSLocalizedString("informationEmailTitle", comment: "")
        passwordLabel.text = NSLocalizedString("informationPasswordTitle", comment: "")
        shipNameLabel.text = NSLocalizedString("informationShipTitle", comment: "")
        legalDescription.text = NSLocalizedString("informationLegalDescription", comment: "")
        deleteButton.setTitle(NSLocalizedString("informationDeleteButton", comment: ""), for: .normal)
        /* name pop up */
        namePopUpDescription.text = NSLocalizedString("namePopUpDescripiton", comment: "")
        nameFieldNameModifier.placeholder = NSLocalizedString("namePopUpPlaceholder", comment: "")
        namePopUpAccept.setTitle(NSLocalizedString("InformationAccept", comment: ""), for: .normal)
        namePopUpCancel.setTitle(NSLocalizedString("InformationCancel", comment: ""), for: .normal)
        /* email pop up */
        emailPopUpDescription.text = NSLocalizedString("emailPopUpDescription", comment: "")
        emailFieldEmailModifier.placeholder = NSLocalizedString("emailPopUpPlaceholder", comment: "")
        passwordFieldEmailModifier.placeholder = NSLocalizedString("passwordPopUpPlaceholder", comment: "")
        emailPopUpAccept.setTitle(NSLocalizedString("InformationAccept", comment: ""), for: .normal)
        emailPopUpCancel.setTitle(NSLocalizedString("InformationCancel", comment: ""), for: .normal)
        /* password pop up */
        passwordPopUpDescription.text = NSLocalizedString("passwordPopUpDescription", comment: "")
        passwordFieldPasswordModifier.placeholder = NSLocalizedString("newPasswordPopUpPlaceholder", comment: "")
        currentPasswordFieldPasswordMofidier.placeholder = NSLocalizedString("currentPasswordPopUpPlaceholder", comment: "")
        passwordPopUpAccept.setTitle(NSLocalizedString("InformationAccept", comment: ""), for: .normal)
        passwordPopUpCancel.setTitle(NSLocalizedString("InformationCancel", comment: ""), for: .normal)
        /* ship name pop up */
        shipPopUpDescripiton.text = NSLocalizedString("shipPopUpDescripiton", comment: "")
        shipFieldShipModifier.placeholder = NSLocalizedString("shipPopUpPlaceholder", comment: "")
        shipPopUpAccept.setTitle(NSLocalizedString("InformationAccept", comment: ""), for: .normal)
        shipPopUpCancel.setTitle(NSLocalizedString("InformationCancel", comment: ""), for: .normal)
        /* deletion pop up */
        deletePopUpDescription.text = NSLocalizedString("deletePopUpDescription", comment: "")
        passwordFieldDeleteModifier.placeholder = NSLocalizedString("passwordPopUpPlaceholder", comment: "")
        deletePopUpAccept.setTitle(NSLocalizedString("InformationAccept", comment: ""), for: .normal)
        deletePopUpCancel.setTitle(NSLocalizedString("InformationCancel", comment: ""), for: .normal)
    }
    
    func setupCustomIcons() {
        nameModifierPic.image = nameModifierPic.image!.withRenderingMode(.alwaysTemplate)
        nameModifierPic.tintColor = registry.customGrey
        emailModifierPic.image = emailModifierPic.image!.withRenderingMode(.alwaysTemplate)
        emailModifierPic.tintColor = registry.customGrey
        shipModifierPic.image = shipModifierPic.image!.withRenderingMode(.alwaysTemplate)
        shipModifierPic.tintColor = registry.customGrey
        passwordModifierPic.image = passwordModifierPic.image!.withRenderingMode(.alwaysTemplate)
        passwordModifierPic.tintColor = registry.customGrey
        
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
        nameContainer.isSkeletonable = true
        emailContainer.isSkeletonable = true
        shipContainer.isSkeletonable = true
        passwordContainer.isSkeletonable = true
        nameContainer.showAnimatedSkeleton()
        emailContainer.showAnimatedSkeleton()
        shipContainer.showAnimatedSkeleton()
        passwordContainer.showAnimatedSkeleton()
        
    }
    
    func turnOffSkeleton() {
        nameContainer.hideSkeleton()
        emailContainer.hideSkeleton()
        shipContainer.hideSkeleton()
        passwordContainer.hideSkeleton()
        
    }
    
    // MARK: - Popup Actions
    
    @IBAction func cancelPopUp(_ sender: Any) {
        animateOut()
        
    }
    
    @IBAction func openChangeName(_ sender: Any) {
        viewStacked = namePopUp
        animateIn(view: namePopUp)
        
    }
    
    @IBAction func openChangeEmail(_ sender: Any) {
        viewStacked = emailPopUp
        animateIn(view: emailPopUp)
        
    }
    
    @IBAction func openChangePassword(_ sender: Any) {
        viewStacked = passwordPopUp
        animateIn(view: passwordPopUp)
        
    }
    
    @IBAction func openChangeShip(_ sender: Any) {
        viewStacked = shipPopUp
        animateIn(view: shipPopUp)
        
    }
    
    @IBAction func deleteHandler(_ sender: Any) {
        viewStacked = deletionPopUp
        animateIn(view: deletionPopUp)
        
    }
    
    // MARK: - Setter Actions
    
    @IBAction func acceptChangeName(_ sender: Any) {
        let name = nameFieldNameModifier.text
        let currentName = self.appUser?.name
        // error checking
        if (name?.isEmpty)! {
            //displayMessage(userMessage: "The new name field is required if you want to change yours Matey!")
            displayMessage(userMessage: NSLocalizedString("changeNameErrorHandler1", comment: ""))
            return
            
        }
        if currentName == name {
            displayMessage(userMessage: NSLocalizedString("changeNameErrorHandler2", comment: ""))
            return
            
        } else {
            let trace = Performance.startTrace(name: self.registry.trace5)
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
            displayMessage(userMessage: NSLocalizedString("changeEmailErrorHandler1", comment: ""))
            return
            
        }
        if newEmail == currentEmail {
            displayMessage(userMessage: NSLocalizedString("changeEmailErrorHandler2", comment: ""))
            return
            
        } else {
            let trace = Performance.startTrace(name: self.registry.trace6)
            let credential = EmailAuthProvider.credential(withEmail: currentEmail!, password: password!)
            // prompt the user to re-provide their sign-in credentials
            self.currentUser?.reauthenticate(with: credential) { authResult, error in
                if let error = error {
                    print("X", error)
                    self.displayMessage(userMessage: NSLocalizedString("reAuthErrorMessage", comment: ""))
                    trace?.stop()
                    return
                    
                } else {
                    // update the user email
                    self.currentUser?.updateEmail(to: newEmail!) { (error) in
                        if error != nil {
                            print("X", error!)
                            self.displayMessage(userMessage: NSLocalizedString("changeEmailErrorMessage", comment: ""))
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
            displayMessage(userMessage: NSLocalizedString("changePasswordErrorHandler1", comment: ""))
            return
            
        }
        if currentPassword == newPassword {
            displayMessage(userMessage: NSLocalizedString("changePasswordErrorHandler2", comment: ""))
            return
            
        } else {
            let trace = Performance.startTrace(name: self.registry.trace7)
            let credential = EmailAuthProvider.credential(withEmail: currentEmail!, password: currentPassword!)
            // prompt the user to re-provide their sign-in credentials
            self.currentUser?.reauthenticate(with: credential) { authResult, error in
                if let error = error {
                    print ("X", error)
                    self.displayMessage(userMessage: NSLocalizedString("reAuthErrorMessage", comment: ""))
                    trace?.stop()
                    return
                    
                } else {
                    // update the user password
                    self.currentUser?.updatePassword(to: newPassword!) { (error) in
                        if error != nil {
                            print("X", error!)
                            self.displayMessage(userMessage: NSLocalizedString("changePasswordErrorMessage", comment: ""))
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
            displayMessage(userMessage: NSLocalizedString("changeShipErrorHandler1", comment: ""))
            return
            
        }
        if shipName == currentShipName {
            displayMessage(userMessage: NSLocalizedString("changeShipErrorHandler2", comment: ""))
            return
            
        } else {
            let trace = Performance.startTrace(name: self.registry.trace8)
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
            displayMessage(userMessage: NSLocalizedString("deleteAccountAdvice", comment: ""))
            return
            
        } else {
            let trace = Performance.startTrace(name: self.registry.trace9)
            let credential = EmailAuthProvider.credential(withEmail: email!, password: password!)
            // prompt the user to re-provide their sign-in credentials
            self.currentUser?.reauthenticate(with: credential) { authResult, error in
                if let error = error {
                    print("X", error)
                    self.displayMessage(userMessage: NSLocalizedString("reAuthErrorMessage", comment: ""))
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
                            self.displayMessage(userMessage: NSLocalizedString("deleteAccountErrorMessage", comment: ""))
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
        let mainTabBarController = storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
        mainTabBarController.selectedViewController = mainTabBarController.viewControllers?[2]
        show(mainTabBarController, sender: self)
        
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
            let trace = Performance.startTrace(name: self.registry.trace10)
            
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
                            let pictureURL = URL(string: self.registry.defaultPictureUrl)
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
