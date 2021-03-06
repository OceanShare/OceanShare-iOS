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
    var ref: DatabaseReference!
    let storageRef = Storage.storage().reference()
    let registry = Registry()
    let skeleton = Skeleton()
    var userName: String?
    
    // MARK: - Outlets
    
    /* view */
    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var mediaLabel: UILabel!
    @IBOutlet weak var editingLabel: UILabel!
    @IBOutlet weak var profileItem: UITabBarItem!
    @IBOutlet weak var subscribeButton: DesignableButton!
    @IBOutlet weak var isSub: UITextView!
    
    /* user information outlets */
    @IBOutlet weak var infoContainer: UIView!
    @IBOutlet weak var pictureContainer: DesignableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var shipName: UILabel!
    
    /* icon outlets */
    @IBOutlet weak var pictureIcon: UIImageView!
    @IBOutlet weak var settingsIcon: UIImageView!
    @IBOutlet weak var editIcon: UIImageView!
    @IBOutlet weak var addEditIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        ref = Database.database().reference()
        setupView()
        fetchUserInfo()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchSubscribtion()
    }
    
    // MARK: - Setup
    
    /**
    - Description - Setup the design of the view.
    */
    func setupView() {
        profilePicture.layer.cornerRadius = 95
        profilePicture.clipsToBounds = true
        setupCustomIcons()
        skeleton.turnOnSkeleton(image: profilePicture, cornerRadius: 65)
        setupLocalizedStrings()
        
    }
    
    /**
    - Description - Setup the translated labels.
    */
    func setupLocalizedStrings() {
        viewTitle.text = NSLocalizedString("profileViewTitle", comment: "")
        settingsLabel.text = NSLocalizedString("profileSettingsLabel", comment: "")
        mediaLabel.text = NSLocalizedString("profileMediaLabel", comment: "")
        editingLabel.text = NSLocalizedString("profileEditLabel", comment: "")
        subscribeButton.setTitle(NSLocalizedString("subButton", comment: ""), for: .normal)
        isSub.text = NSLocalizedString("isSubTextField", comment: "")
        
    }
    
    /**
    - Description - Setup icon design.
    */
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
    
    // MARK: - Actions
    
    /**
     - Description - Change the user profile picture.
     */
    @IBAction func changeProfilePicture(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.modalPresentationStyle = .fullScreen
        present(picker, animated: true, completion: nil)
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        present(picker, animated: true, completion: nil)
        
    }
    
    // MARK: - Updater
    
    /**
     - Description - Check if the user is premium or not and displays or not the offers.
     */
    func fetchSubscribtion() {
        let currentDate = NSDate() as Date
        
        if Defaults.getUserDetails().subEnd.timeIntervalSince(currentDate).sign == FloatingPointSign.minus {
            print("-> not premium")
            subscribeButton.isHidden = false
            isSub.isHidden = true
            
        } else {
            print("-> premium")
            subscribeButton.isHidden = true
            isSub.isHidden = false
            
        }
    }
    
    /**
     - Description - Get the user data and displays it on the view.
     */
    func fetchUserInfo() {
        let userId = User.getCurrentUser()
        
        ref.child("users").child(userId).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot == snapshot {
                let userData = User(dataSnapshot: snapshot as DataSnapshot)
                
                self.titleLabel.text = NSLocalizedString("hello", comment: "") + userData.name! + " !"
                if userData.shipName!.isEmpty {
                    self.shipName.text = ""
                } else {
                    self.shipName.text = "\" " + userData.shipName! + " \""
                }
                
                let user = Auth.auth().currentUser
                let trace = Performance.startTrace(name: self.registry.trace3)
                
                if let user = user {
                    _ = Storage.storage().reference().child("profile_pictures").child("\(String(describing: user.uid)).png").downloadURL(completion: { (url, error) in
                        if error != nil {
                            // check if the user has a network profile picture
                            if let userPicture = userData.picture {
                                let pictureURL = URL(string: userPicture)
                                let pictureData = NSData(contentsOf: pictureURL!)
                                let finalPicture = UIImage(data: pictureData! as Data)
                                self.profilePicture.image = finalPicture

                            } else {
                                // set a default avatar
                                let pictureURL = URL(string: self.registry.defaultPictureUrl)
                                let pictureData = NSData(contentsOf: pictureURL!)
                                let finalPicture = UIImage(data: pictureData! as Data)
                                self.profilePicture.image = finalPicture
                                
                            }
                        } else {
                            // set the custom profile picture if the user has one
                            let pictureData = NSData(contentsOf: url!)
                            let finalPicture = UIImage(data: pictureData! as Data)
                            self.profilePicture.image = finalPicture
                            
                        }
                        self.pictureContainer.hideSkeleton()
                        
                    })
                } else {
                    print("X Error: cannot get current user.")
                    trace?.stop()
                    return
                    
                }
                trace?.stop()
            }
        }
    }
    
    // MARK: - Picker
    
    /**
     - Description - Open the image picker controller.
     - Inputs - picker `UIImagePickerController` & info `[UIImagePickerController.InfoKey: Any]`
     */
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
            if let uploadImage = selectedImage.jpegData(compressionQuality: 0.6) {
                let name = Defaults.getUserDetails().name
                updateProfileInfo(withImage: uploadImage, name: name)
            }
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    /**
     - Description - Dismiss the image picker if the cancel button is tapped
     - Inputs - picker `UIImagePickerController`
     */
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        
    }
    
    /**
     - Description - Swift 4 function to convert value.
     - Inputs - input `[UIImagePickerController.InfoKey: Any]`
     - Output - `[String: Any]` photo library information
     */
    func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
        
    }
    
    // MARK: - Storage
    
    /**
     - Description - Create a request to change the profile data.
     - Inputs - photoUrl `URL` & name `String`
     */
    func createProfileChangeRequest(photoUrl: URL? = nil, name: String? = nil, _ callback: ((Error?) -> ())? = nil) {
        if let request = Auth.auth().currentUser?.createProfileChangeRequest(){
            if let name = name {
                request.displayName = name
                
            }
            if let url = photoUrl {
                request.photoURL = url
                
            }
            
            request.commitChanges(completion: { (error) in
                callback?(error)
                
            })
        }
    }
    
    /**
     - Description - Update the user information on the database.
     - Inputs - image `Data` & name `String`
     */
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
                        if let url = url {
                            self.createProfileChangeRequest(photoUrl: url, name: name, { (error) in
                                callback?(error)
                            })
                            Defaults.save(Defaults.getUserDetails().name, name: Defaults.getUserDetails().name, email: Defaults.getUserDetails().email, picture: String(describing: url), shipName: Defaults.getUserDetails().shipName, boatId: Defaults.getUserDetails().boatId, ghostMode: Defaults.getUserDetails().ghostMode, showPicture: Defaults.getUserDetails().showPicture, isEmail: Defaults.getUserDetails().isEmail, isCelsius: Defaults.getUserDetails().isCelsius, subEnd: Defaults.getUserDetails().subEnd)
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
