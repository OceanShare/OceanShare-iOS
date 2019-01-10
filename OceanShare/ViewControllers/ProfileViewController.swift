//
//  ProfileViewController.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 31/12/2018.
//  Copyright © 2018 Joseph Pereniguez. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore
import FirebaseStorage
import GoogleSignIn

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: definitions
    
    var ref: DatabaseReference!
    let storageRef = FirebaseStorage.Storage().reference()
    var appUser: AppUser? {
        didSet {
            guard let name = appUser?.name else { return }
            guard let emailAddress = appUser?.email else { return }
            
            navigationItem.title = "Profile"
            titleLabel.text = "Hello " + name + " !"
            userName.text = name
            userEmailAddress.text = emailAddress
            userShipName.text = "Axe Boat"
        }
    }
    
    // MARK: outlets

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmailAddress: UILabel!
    @IBOutlet weak var userShipName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        fetchUserInfo()
        
        
        userImage.image = UIImage(named: "OceanShare_Profile_Pick")
        userImage.translatesAutoresizingMaskIntoConstraints = false
        userImage.contentMode = .scaleAspectFill
        
        userImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        userImage.isUserInteractionEnabled = true
        
    }
    
    @objc func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            userImage.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    }

    // MARK: actions
    
    /*@IBAction func uploadImageButton(_ sender: UIButton) {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(picker, animated: true, completion: nil)
        
    }*/
    
    @IBAction func handleLogout(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            //Todo: find a way to return to pageviewcontroller -> startviewcontroller
            let signInPage = self.storyboard!.instantiateViewController(withIdentifier: "LoginViewController")
            let appDelegate = UIApplication.shared.delegate
            appDelegate?.window??.rootViewController = signInPage
            print("User has correctly logged out.")
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    /*@IBAction func handleSave(_ sender: UIButton) {
        
        print("Saving changes.")
        saveChanges()
        
    }*/
    
    // MARK: functions
    
    /*func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker {
            profileImage.image = selectedImageFromPicker
        }
        dismiss(animated: true, completion: nil)
    }*/
    
    /*func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }*/
    
    /*func saveChanges() {
        let imageName = NSUUID().uuidString
        let storedImage = storageRef.child("profileImage").child(imageName)
        
        if let uploadData = self.profileImage.image!.pngData() {
            storedImage.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                storedImage.downloadURL(completion: { (url, error) in
                    if error != nil {
                        print(error!.localizedDescription)
                        return
                    }
                    if let urlText = url?.absoluteString{
                        self.ref.child("users").child((Auth.auth().currentUser?.uid)!).updateChildValues(["pic": urlText], withCompletionBlock: { (error, ref) in
                            if error != nil {
                                print(error?.localizedDescription as Any)
                                return
                            }
                        })
                    }
                })
            })
        }
        
    }*/
    
    func fetchUserInfo() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        ref.child("users").child(userId).observeSingleEvent(of: .value) { (snapshot) in
            guard let data = snapshot.value as? NSDictionary else { return }
            guard let userName = data["name"] as? String else { return }
            guard let userEmail = data["email"] as? String else { return }
            
            // self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width/2
            /*self.profileImage.clipsToBounds = true*/
            
            self.appUser = AppUser(name: userName, uid: userId, email: userEmail)
            
            if let dict = snapshot.value as? [String: AnyObject] {
                if let profileImageUrl = dict["pic"] as? String {
                    let url = URL(string: profileImageUrl)
                    URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                        if error != nil {
                            print(error?.localizedDescription as Any)
                            return
                        }
                        DispatchQueue.main.async {
                            /*self.profileImage.image = UIImage(data: data!)*/
                        }
                    }).resume()
                }
            }
        }
    }
}
