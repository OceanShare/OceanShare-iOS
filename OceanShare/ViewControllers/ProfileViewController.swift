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
        //setupProfile()
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
            
            let uploadImage = selectedImage.jpegData(compressionQuality: 0.6)
            updateProfileInfo(withImage: uploadImage, name: appUser!.name)
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
    
    func fetchUserInfo() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        ref.child("users").child(userId).observeSingleEvent(of: .value) { (snapshot) in
            guard let data = snapshot.value as? NSDictionary else { return }
            guard let userName = data["name"] as? String else { return }
            guard let userEmail = data["email"] as? String else { return }
            
            self.appUser = AppUser(name: userName, uid: userId, email: userEmail)
        }
    }
    
    /*func setupProfile() {
        
        // retrieving user info like name, email and profile picture if there is one
        if let userId = Auth.auth().currentUser?.uid {
            ref.child("users").child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dict = snapshot.value as? [String: AnyObject] {
                    self.userEmailAddress.text = dict["email"] as? String
                    self.userName.text = dict["name"] as? String
                    
                    if let profileImageURL = dict["pic"] as? String
                    {
                        let url = URL(string: profileImageURL)
                        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                            if error != nil {
                                print(error!)
                                return
                            }
                            DispatchQueue.main.async {
                                self.profilePicture?.image = UIImage(data: data!)
                            }
                        }).resume()
                    }
                }
            })
            
        }
    }*/
    
    // MARK: actions
    
    @IBAction func changeProfilePicture(_ sender: UIButton) {
        let picker = UIImagePickerController()
        present(picker, animated: true, completion: nil)
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
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
    
    // MARK: storage functions
    
    func createProfileChangeRequest(photoUrl: URL? = nil, name: String? = nil, _ callback: ((Error?) -> ())? = nil){
        if let request = Auth.auth().currentUser?.createProfileChangeRequest(){
            if let name = name{
                request.displayName = name
            }
            if let url = photoUrl{
                request.photoURL = url
            }
            
            request.commitChanges(completion: { (error) in
                callback?(error)
            })
        }
    }
    
    func updateProfileInfo(withImage image: Data? = nil, name: String? = nil, _ callback: ((Error?) -> ())? = nil){
        guard let user = Auth.auth().currentUser else {
            callback?(nil)
            return
        }
        
        if let image = image {
            let profileImgReference = Storage.storage().reference().child("profile_pictures").child("\(user.uid).png")
            
            _ = profileImgReference.putData(image, metadata: nil) { (metadata, error) in
                if let error = error {
                    callback?(error)
                } else {
                    profileImgReference.downloadURL(completion: { (url, error) in
                        if let url = url{
                            self.createProfileChangeRequest(photoUrl: url, name: name, { (error) in
                                callback?(error)
                            })
                        } else {
                            callback?(error)
                        }
                    })
                }
            }
        } else if let name = name {
            self.createProfileChangeRequest(name: name, { (error) in
                callback?(error)
            })
        } else {
            callback?(nil)
        }
    }

}
