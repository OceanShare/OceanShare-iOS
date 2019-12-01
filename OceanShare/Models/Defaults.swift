//
//  Defaults.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 01/12/2019.
//  Copyright © 2019 Joseph Pereniguez. All rights reserved.
//

import Foundation

struct Defaults {
    
    static let (uidKey, nameKey, emailKey, pictureKey, shipNameKey, boatIdKey, ghostModeKey, showPictureKey) = ("uid", "name", "email", "picture", "shipName", "boatId", "ghostMode", "showPicture")
    static let userSessionKey = "com.save.usersession"
    private static let userDefault = UserDefaults.standard
    
    /**
       - Description - It's using for the passing and fetching
                    user values from the UserDefaults.
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
        
        init(_ json: [String: String]) {
            self.uid = json[uidKey] ?? ""
            self.name = json[nameKey] ?? ""
            self.email = json[emailKey] ?? ""
            self.picture = json[pictureKey] ?? ""
            self.shipName = json[shipNameKey] ?? ""
            self.boatId = Int(json[boatIdKey]!) ?? 1
            self.ghostMode = Bool(json[ghostModeKey]!) ?? false
            self.showPicture = Bool(json[showPictureKey]!) ?? true
        }
    }
    
    /**
     - Description - Saving user details
     - Inputs - name `String` & email `String` & picture `String` & shipName `String` & boatId `Int` & ghostMode `Bool` & showPicture `Bool`
     */
    static func save(_ uid: String, name: String, email: String, picture: String, shipName: String, boatId: Int, ghostMode: Bool, showPicture: Bool){
        userDefault.set([uidKey: uid, nameKey: name, emailKey: email, pictureKey: picture, shipNameKey: shipName, boatIdKey: boatId, ghostModeKey: ghostMode, showPictureKey: showPicture],
                        forKey: userSessionKey)
    }
    
    /**
     - Description - Fetching Values via Model `UserDetails` you can use it based on your uses.
     - Output - `UserDetails` model
     */
    static func getUserDetails()-> UserDetails {
        return UserDetails((userDefault.value(forKey: userSessionKey) as? [String: String]) ?? [:])
    }
    
    /**
        - Description - Clearing user details for the user key `com.save.usersession`
     */
    static func clearUserData(){
        userDefault.removeObject(forKey: userSessionKey)
    }
}
