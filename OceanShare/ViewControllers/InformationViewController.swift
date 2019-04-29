//
//  InformationViewController.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 11/04/2019.
//  Copyright © 2019 Joseph Pereniguez. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore
import FirebaseStorage
import GoogleSignIn

class InformationViewController: UIViewController {
    
    // MARK: Definitions
    
    var passwordStacked: String?
    var emailStacked: String?
    
    // MARK: Databse
    
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
    
    // MARK: Outlets
    
    @IBOutlet weak var nameModifierPic: UIImageView!
    @IBOutlet weak var emailModifierPic: UIImageView!
    @IBOutlet weak var shipModifierPic: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmailAddress: UILabel!
    @IBOutlet weak var userShipName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        // apply the design stuff to the view
        setupView()
        // get the profile picture and the user name
        self.fetchUserInfo()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        fetchUserInfo()
        
    }
    
    // MARK: Setup
    
    func setupView() {
        self.nameModifierPic.image = self.nameModifierPic.image!.withRenderingMode(.alwaysTemplate)
        self.nameModifierPic.tintColor = UIColor(rgb: 0xC5C7D2)
        self.emailModifierPic.image = self.emailModifierPic.image!.withRenderingMode(.alwaysTemplate)
        self.emailModifierPic.tintColor = UIColor(rgb: 0xC5C7D2)
        self.shipModifierPic.image = self.shipModifierPic.image!.withRenderingMode(.alwaysTemplate)
        self.shipModifierPic.tintColor = UIColor(rgb: 0xC5C7D2)
        
    }
    
    // MARK: Actions
    
    @IBAction func openChangeName(_ sender: Any) {
        self.nameModifierPic.tintColor = UIColor(rgb: 0x57A1FF)
        let alert = UIAlertController(title: "Tap a new name.", message: "Write a new name in the field below then accept to change your user name.", preferredStyle: .alert)
        alert.addTextField { (newNameField : UITextField!) -> Void in
            newNameField.placeholder = "Enter New Name"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
            print("~ Action Informations: Cancel Pressed.")
            self.nameModifierPic.tintColor = UIColor(rgb: 0xC5C7D2)
        }))
        alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: { action in
            let newNameField = alert.textFields![0] as UITextField
            self.changeName(name: newNameField.text!)
            print("~ Action Informations: Name has been changed.")
            self.nameModifierPic.tintColor = UIColor(rgb: 0xC5C7D2)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func openChangeEmail(_ sender: Any) {
        self.emailModifierPic.tintColor = UIColor(rgb: 0x57A1FF)
        let alert = UIAlertController(title: "Tap a new email.", message: "Write a new name in the field below then accept to change your email.", preferredStyle: .alert)
        alert.addTextField { (newEmailField : UITextField!) -> Void in
            newEmailField.placeholder = "Enter New Email"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
            print("~ Action Informations: Cancel Pressed.")
            self.emailModifierPic.tintColor = UIColor(rgb: 0xC5C7D2)
        }))
        alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: { action in
            let newEmailField = alert.textFields![0] as UITextField
            self.changeEmail(email: newEmailField.text!)
            print("~ Action Informations: Email has been changed.")
            self.emailModifierPic.tintColor = UIColor(rgb: 0xC5C7D2)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func openChangeShip(_ sender: Any) {
        self.shipModifierPic.tintColor = UIColor(rgb: 0x57A1FF)
        let alert = UIAlertController(title: "Tap a new name.", message: "Write a new name in the field below then accept to change your ship name.", preferredStyle: .alert)
        alert.addTextField { (newShipField : UITextField!) -> Void in
            newShipField.placeholder = "Enter Your Ship Name"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
            print("~ Action Informations: Cancel Pressed.")
            self.shipModifierPic.tintColor = UIColor(rgb: 0xC5C7D2)
        }))
        alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: { action in
            let newShipField = alert.textFields![0] as UITextField
            self.changeShipName(ship: newShipField.text!)
            print("~ Action Informations: Ship name has been changed.")
            self.shipModifierPic.tintColor = UIColor(rgb: 0xC5C7D2)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
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
            self.passwordStacked = password.text!
            self.deleteAccount()
            print("~ Action Informations: Account is going to be deleted.")
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: Updater
    
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
    
    // MARK: Setters
    
    // handle the account deletion
    func deleteAccount() {
        let user = Auth.auth().currentUser
        let credential = EmailAuthProvider.credential(withEmail: self.emailStacked!, password: self.passwordStacked!)
        
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
                        print("~ Action Informations: User Deleted")
                        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                        self.present(loginViewController, animated: true ,completion: nil)
                    }
                }
                
            }
        }
        
    }
    
    // handle the email changes
    func changeEmail(email: String) {
        let user = Auth.auth().currentUser
        
        // define the database structure
        let userData: [String: Any] = ["email": email as Any]
        
        // update the user data on the database
        guard let uid = user?.uid else { return }
        self.ref.child("users/\(uid)").updateChildValues(userData)
        self.userEmailAddress.text = email
        
    }
    
    // handle the name changes
    func changeName(name: String) {
        let user = Auth.auth().currentUser
        
        // define the database structure
        let userData: [String: Any] = ["name": name as Any]
        
        // update the user data on the database
        guard let uid = user?.uid else { return }
        self.ref.child("users/\(uid)").updateChildValues(userData)
        self.userName.text = name
        
    }
    
    // handle the ship name changes
    func changeShipName(ship: String) {
        let user = Auth.auth().currentUser
        
        // define the database structure
        let userData: [String: Any] = ["ship_name": ship as Any]
        
        // update the user data on the database
        guard let uid = user?.uid else { return }
        self.ref.child("users/\(uid)").updateChildValues(userData)
        self.userShipName.text = ship
        
    }
    
}
