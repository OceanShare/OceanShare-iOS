//
//  FireBaseManager.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 21/05/2019.
//  Copyright © 2019 Joseph Pereniguez. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore
import FirebaseStorage

class FirebaseManager {
    static let shared = FirebaseManager()
    private let reference = Database.database().reference()
}

// MARK: - Removing functions

extension FirebaseManager {
    public func removePost(withID: String) {
        
        let reference = self.reference.child("Tag").child(withID)
        reference.removeValue { error, _ in
            print(error?.localizedDescription as Any)
        }
    }
}
