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

    // MARK: database definition
    
    var ref: DatabaseReference!
    let storageRef = FirebaseStorage.Storage().reference()
    var appUser: AppUser? {
        didSet {
            guard let name = appUser?.name else { return }
            guard let emailAddress = appUser?.email else { return }
            
            titleLabel.text = "Hello " + name + " !"
            userName.text = name
            userEmailAddress.text = emailAddress
            userShipName.text = "Axe Boat"
        }
    }
    
    // MARK: outlets

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmailAddress: UILabel!
    @IBOutlet weak var userShipName: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        
        setupView()
        fetchUserInfo()
    }
    
    // MARK: image picker functions
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker: UIImage?
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        if let editedImage = info ["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profilePicture.image = selectedImage
            
            // upload the profile picture after picking
            /*uploadPicture(profilePicture.image!) { url in
            
                if url != nil {
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = self.appUser?.name
                    changeRequest?.photoURL = url
                    
                    changeRequest?.commitChanges { error in
                        if error == nil {
                            print("User display name changed!")
                            
                            self.saveProfile(username: (self.appUser?.name)!, profileImageURL: url!) { success in
                                if success {
                                    print("Success")
                                }
                            }
                            
                        } else {
                            print (error!.localizedDescription)
                        }
                    }
                } else {
                    // error unable to upload profile image
                }
            }*/
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // dismiss the image picker if the cancel button is tapped
        dismiss(animated: true, completion: nil)
    }
    
    func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        // swift 4 function to convert value
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    }

    // MARK: setup function
    
    func setupView() {
        self.profilePicture.layer.cornerRadius = 75
        self.profilePicture.clipsToBounds = true
    }
    
    // MARK: actions
    
    @IBAction func changeProfilePicture(_ sender: UIButton) {
        let picker = UIImagePickerController()
        present(picker, animated: true, completion: nil)
        picker.delegate = self
        picker.allowsEditing = true
        //picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
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
    
    // MARK: upload
    
    func uploadPicture(_ image: UIImage, completion: @escaping ((_ url:URL?)->())) {
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let storageRef = FirebaseStorage.Storage().reference().child("user/\(userId)")
        
        if let uploadData = self.profilePicture.image!.pngData() {
            
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
            
        storageRef.putData(uploadData, metadata: metaData) { metaData, error in
            if error == nil, metaData != nil {
                storageRef.downloadURL(completion: { (url, error) in
                    if error != nil {
                        print("Failed to download url:", error!)
                        completion(nil)
                    } else {
                        completion(url)
                    }
                })
            } else {
                completion(nil)
            }}
        }
    }
    
    func saveProfile(username: String, profileImageURL: URL, completion: @escaping ((_ success:Bool)->())) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let databaseRef = Database.database().reference().child("users/profile/\(userId)")
        
        let userObject = [
            "photoURL": profileImageURL
        ] as [String:Any]
        
        databaseRef.setValue(userObject) { error, ref in
            completion(error == nil)
        }
    }
    
    // MARK: fetch
    
    func fetchUserInfo() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        ref.child("users").child(userId).observeSingleEvent(of: .value) { (snapshot) in
            guard let data = snapshot.value as? NSDictionary else { return }
            guard let userName = data["name"] as? String else { return }
            guard let userEmail = data["email"] as? String else { return }
            
            self.appUser = AppUser(name: userName, uid: userId, email: userEmail)
            
        }
    }
}
