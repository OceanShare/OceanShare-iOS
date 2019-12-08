//
//  User.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 27/10/2019.
//  Copyright © 2019 Joseph Pereniguez. All rights reserved.
//

import UIKit
import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore
import FirebaseStorage
import FirebasePerformance

struct User {
    var name: String?
    var uid: String?
    var email: String?
    var picture: String?
    var shipName: String?
    var longitude: Double?
    var latitude: Double?
    var ghostMode: Bool?
    var boatId: Int?
    var showPicture: Bool?
    var isActive: Bool?
 
    init(dataSnapshot: DataSnapshot) {
        uid = dataSnapshot.key
        
        let data = dataSnapshot.value as? NSDictionary
        name = data?["name"] as? String
        email = data?["email"] as? String
        
        if let tempShipName = data?["ship_name"] as? String {
            shipName = tempShipName
        } else {
            shipName = ""
        }
        
        if let tempPicture = data?["picture"] as? String {
            picture = tempPicture
        } else {
            picture = nil
        }
        
        let location = data?["location"] as? [String: AnyObject]
        let longitudeAsString = location?["longitude"] as? String
        let latitudeAsString = location?["latitude"] as? String
        longitude = longitudeAsString?.toDouble()
        latitude = latitudeAsString?.toDouble()
        
        let preferences = data?["preferences"] as? [String: AnyObject]
        ghostMode = preferences?["ghost_mode"] as? Bool
        boatId = preferences?["boatId"] as? Int
        showPicture = preferences?["show_picture"] as? Bool
        isActive = preferences?["user_active"] as? Bool
        
    }
    
    // MARK: - Functions
    
    /**
     - Description - Get the logged user id.
     - Output - `String` uid
     */
    static func getCurrentUser() -> String {
        let userId = Auth.auth().currentUser?.uid
        return (userId ?? "Cannot get User")
        
    }
    
    /**
     - Description - Return the user picture url from the database if there is one, else return the default user picture url.
     - Inputs - user `User`
     - Output - `UIImage` profile picture
     */
    func getUserPictureFromDatabase(user: User) -> UIImage {
        if (user.picture != nil) {
            let pictureURL = URL(string: user.picture!)
            let pictureData = NSData(contentsOf: pictureURL!)
            let finalPicture = UIImage(data: pictureData! as Data)
            return self.getAvatarCheckIn(user: user, finalPicture: finalPicture!)
        }
        return getDefaultPicture()
        
    }
    
    /**
     - Description - Return the default user picture url from calling the function getDefaultPicture.
     - Inputs - user `User`
     - Output - `UIImage` profile picture
     */
    func getUserPictureFromNowhere(user: User) -> UIImage {
        return self.getAvatarCheckIn(user: user, finalPicture: self.getDefaultPicture())
        
    }
    
    /**
     - Description - Return the user picture uploaded in storage if there is one, else return the default user picture url.
     - Inputs - user `User` & url `URL`
     - Output - `UIImage` profile picture
     */
    func getUserPictureFromStorage(user: User, url: URL) -> UIImage {
        let pictureData = NSData(contentsOf: url)
        let finalPicture = UIImage(data: pictureData! as Data)
        return self.getAvatarCheckIn(user: user, finalPicture: finalPicture!)
        
    }
    
    /**
     - Description - Return the default user picture url.
     - Output - `UIImage` default profile picture
     */
    func getDefaultPicture() -> UIImage {
        let registry = Registry()
        let pictureURL = URL(string: registry.defaultPictureUrl)
        let pictureData = NSData(contentsOf: pictureURL!)
        return UIImage(data: pictureData! as Data)!
        
    }
    
    /**
     - Description - Return the avatar depending of the user boat type if there is a boatId, else return the default user picture url.
     - Inputs - user `User` & finalPicture `UIImage`
     - Output - `UIImage` avatar image
     */
    func getAvatarCheckIn(user: User, finalPicture: UIImage) -> UIImage {
        if (user.showPicture == true) {
            return finalPicture
        } else {
            switch user.boatId {
            case 1:
                return UIImage(named: "sailing_boat")!
            case 2:
                return UIImage(named: "mini_gondola")!
            case 3:
                return UIImage(named: "mini_yacht")!
            case 4:
                return UIImage(named: "yacht")!
            default:
                return self.getDefaultPicture()
                
            }
        }
    }
}
