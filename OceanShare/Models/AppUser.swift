//
//  AppUser.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 28/12/2018.
//  Copyright © 2018 Joseph Pereniguez. All rights reserved.
//

import UIKit
import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore
import FirebaseStorage
import FirebasePerformance

struct AppUser {
    var name: String?
    var uid: String?
    var email: String?
    var picture: UIImage?
    var ship_name: String?
        
    // MARK: - User Manager Functions
    
    static func getCurrentUser() -> String {
        let userId = Auth.auth().currentUser?.uid
        return (userId ?? "Cannot get User")
        
    }

}
