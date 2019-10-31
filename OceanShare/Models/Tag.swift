//
//  Tag.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 27/04/2019.
//  Copyright © 2019 Joseph Pereniguez. All rights reserved.
//

import Foundation
import UIKit
import Mapbox

struct Tag {
    var description: String?
    var id: Int?
    var latitude: Double?
    var longitude: Double?
    var time: String?
    var user: String?
    var timestamp: Any?
    var upvote: Int?
    var downvote: Int?
    var contributors: [String:Int]?
    
//    init(dataSnapshot: DataSnapshot) {
//        id = dataSnapshot.key
//
//        
//
//    }
    
}
