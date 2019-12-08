//
//  Connectivity.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 08/12/2019.
//  Copyright © 2019 Joseph Pereniguez. All rights reserved.
//

import Foundation
import Alamofire

struct Connectivity {
    static let sharedInstance = NetworkReachabilityManager()!
    static var isConnectedToInternet:Bool {
        return self.sharedInstance.isReachable
    
    }
    
}
