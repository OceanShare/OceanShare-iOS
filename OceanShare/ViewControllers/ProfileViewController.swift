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
import SkeletonView
import FirebasePerformance

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Database
    
    var ref: DatabaseReference!
    let storageRef = FirebaseStorage.Storage().reference()
    let registry = Registry()
    
    var appUser: AppUser? {
        didSet {
            guard let name = appUser?.name else { return }
            guard let picture = appUser?.picture else { return }
            guard let ship = appUser?.ship_name else { return }
            
            profilePicture.image = picture
            titleLabel.text = "Ahoy " + name + " !"
            shipName.text = "\" " + ship + " \""
        }
    }
    
    // MARK: - Outlets
    
    // user information outlets
    @IBOutlet weak var infoContainer: UIView!
    @IBOutlet weak var pictureContainer: DesignableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var shipName: UILabel!
    
    // icon outlets
    @IBOutlet weak var pictureIcon: UIImageView!
    @IBOutlet weak var settingsIcon: UIImageView!
    @IBOutlet weak var editIcon: UIImageView!
    @IBOutlet weak var addEditIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()

        setupView()
        fetchUserInfo()
        
    }
    
    // MARK: - Setup
    
    func setupView() {
        // setup the profile picture and its container
        profilePicture.layer.cornerRadius = 95
        profilePicture.clipsToBounds = true
        // setup the icons
        setupCustomIcons()
        // setup the skeleton animation
        turnOnSkeleton()
        
    }
    
    func setupCustomIcons() {
        settingsIcon.image = settingsIcon.image!.withRenderingMode(.alwaysTemplate)
        settingsIcon.tintColor = registry.customGrey
        editIcon.image = editIcon.image!.withRenderingMode(.alwaysTemplate)
        editIcon.tintColor = registry.customGrey
        pictureIcon.image = pictureIcon.image!.withRenderingMode(.alwaysTemplate)
        pictureIcon.tintColor = registry.customWhite
        addEditIcon.image = addEditIcon.image!.withRenderingMode(.alwaysTemplate)
        addEditIcon.tintColor = registry.customClearBlue
        
    }
    
    // MARK: - Animations
    
    func turnOnSkeleton() {
        let gradient = SkeletonGradient(baseColor: UIColor.clouds)
        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .topLeftBottomRight)
        profilePicture.isSkeletonable = true
        profilePicture.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
        
    }
    
    func turnOffSkeleton() {
        pictureContainer.hideSkeleton()
        
    }
    
    // MARK: - Actions
    
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
            if Auth.auth().currentUser == nil {
                // Remove User Session from device
                UserDefaults.standard.removeObject(forKey: "user_uid_key")
                UserDefaults.standard.synchronize()
                let signInPage = self.storyboard!.instantiateViewController(withIdentifier: "LoginViewController")
                let appDelegate = UIApplication.shared.delegate
                appDelegate?.window??.rootViewController = signInPage
                print("-> User has correctly logged out.")
                
            }
        } catch let signOutError as NSError {
            print ("X Error signing out: %@", signOutError)
            
        }
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
                self.shipName.text = "\" " + defaultShipName + " \""
                self.fetchUserInfo()
                return
                
            }
            
            let user = Auth.auth().currentUser
            let trace = Performance.startTrace(name: self.registry.trace3)
            
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
                print("X Error User Not Found In The Storage.")
                trace?.stop()
                return
                
            }
            trace?.stop()
            
        }
    }
    
    // MARK: - Picker
    
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
            // convert the selected image to jpeg and compress it
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
    
    // MARK: - Storage
    
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
