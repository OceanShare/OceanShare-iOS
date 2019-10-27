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
}
