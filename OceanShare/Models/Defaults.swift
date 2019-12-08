//
//  Defaults.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 01/12/2019.
//  Copyright © 2019 Joseph Pereniguez. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseCore
import GoogleSignIn
import FBSDKLoginKit

struct Defaults {
    static let (uidKey, nameKey, emailKey, pictureKey, shipNameKey, boatIdKey, ghostModeKey, showPictureKey, isEmailKey, isCelsiusKey) = ("uid", "name", "email", "picture", "shipName", "boatId", "ghostMode", "showPicture", "isEmail", "isCelsius")
    static let userSessionKey = "com.save.usersession"
    private static let userDefault = UserDefaults.standard
    
    /**
     - Description - Structure using for the passing and fetching user values from the UserDefaults.
     */
    struct UserDetails {
        let uid: String
        let name: String
        let email: String
        let picture: String
        let shipName: String
        let boatId: Int
        let ghostMode: Bool
        let showPicture: Bool
        let isEmail: Bool
        let isCelsius: Bool
        
        init(_ json: [String: Any]) {
            self.uid = json[uidKey] as? String ?? ""
            self.name = json[nameKey] as? String ?? ""
            self.email = json[emailKey] as? String ?? ""
            self.picture = json[pictureKey] as? String ?? ""
            self.shipName = json[shipNameKey] as? String ?? ""
            self.boatId = json[boatIdKey] as? Int ?? 1
            self.ghostMode = json[ghostModeKey] as? Bool ?? false
            self.showPicture = json[showPictureKey] as? Bool ?? false
            self.isEmail = json[isEmailKey] as? Bool ?? false
            self.isCelsius = json[isCelsiusKey] as? Bool ?? true
        
        }
    }
    
    /**
     - Description - Saving user details.
     - Inputs - name `String` & email `String` & picture `String` & shipName `String` & boatId `Int` & ghostMode `Bool` & showPicture `Bool`
     */
    static func save(_ uid: String, name: String, email: String, picture: String, shipName: String, boatId: Int, ghostMode: Bool, showPicture: Bool, isEmail: Bool, isCelsius: Bool){
        userDefault.set([uidKey: uid, nameKey: name, emailKey: email, pictureKey: picture, shipNameKey: shipName, boatIdKey: boatId, ghostModeKey: ghostMode, showPictureKey: showPicture, isEmailKey: isEmail, isCelsiusKey: isCelsius],
                        forKey: userSessionKey)
    }
    
    /**
     - Description - Fetching Values via Model `UserDetails` you can use it based on your uses.
     - Output - `UserDetails` model
     */
    static func getUserDetails()-> UserDetails {
        return UserDetails((userDefault.value(forKey: userSessionKey) as? [String: Any]) ?? [:])
    }
    
    /**
     - Description - Clearing user details for the user key `com.save.usersession`.
     */
    static func clearUserData(){
        userDefault.removeObject(forKey: userSessionKey)
    }
    
    
    /**
     - Description - Fetching user information from database then feeding `com.save.usersession` with the retrieved data.
     - Inputs - uid `String` & isEmail `Bool`
     */
    static func feedDefault(uid: String, isEmail: Bool) {
        let userRef = Database.database().reference().child("users")
        
        
        if isEmail == true {
            userRef.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot == snapshot {
                    let userData = User(dataSnapshot: snapshot as DataSnapshot)
                    _ = Defaults.save(uid, name: userData.name!, email: userData.email!, picture: userData.picture ?? "", shipName: userData.shipName ?? "", boatId: userData.boatId!, ghostMode: userData.ghostMode!, showPicture: userData.showPicture!, isEmail: true, isCelsius: true)
                
                }
            })
        } else {
            userRef.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot == snapshot {
                    let userData = User(dataSnapshot: snapshot as DataSnapshot)
                    _ = Defaults.save(uid, name: userData.name!, email: userData.email!, picture: userData.picture ?? "", shipName: userData.shipName ?? "", boatId: userData.boatId!, ghostMode: userData.ghostMode!, showPicture: userData.showPicture!, isEmail: false, isCelsius: true)
                
                }
            })
        }
    }
    
}
