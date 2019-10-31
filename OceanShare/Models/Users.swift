//
//  Users.swift
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

struct Users {
    var name: String?
    var uid: String?
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
        
        if let tempShipName = data?["ship_name"] as? String {
            shipName = tempShipName
        } else {
            shipName = nil
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
    
    func getUserPictureFromDatabase(user: Users) -> UIImage {
        if (user.picture != nil) {
            let pictureURL = URL(string: user.picture!)
            let pictureData = NSData(contentsOf: pictureURL!)
            let finalPicture = UIImage(data: pictureData! as Data)
            return self.getAvatarCheckIn(user: user, finalPicture: finalPicture!)
        }
        return getDefaultPicture()
        
    }
    
    func getUserPictureFromNowhere(user: Users) -> UIImage {
        return self.getAvatarCheckIn(user: user, finalPicture: self.getDefaultPicture())
        
    }
    
    func getUserPictureFromStorage(user: Users, url: URL) -> UIImage {
        let pictureData = NSData(contentsOf: url)
        let finalPicture = UIImage(data: pictureData! as Data)
        return self.getAvatarCheckIn(user: user, finalPicture: finalPicture!)
        
    }
    
    func getDefaultPicture() -> UIImage {
        let registry = Registry()
        let pictureURL = URL(string: registry.defaultPictureUrl)
        let pictureData = NSData(contentsOf: pictureURL!)
        return UIImage(data: pictureData! as Data)!
        
    }
    
    func getAvatarCheckIn(user: Users, finalPicture: UIImage) -> UIImage {
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
