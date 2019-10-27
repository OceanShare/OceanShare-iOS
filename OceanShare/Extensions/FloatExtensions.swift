//
//  FloatExtensions.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 27/10/2019.
//  Copyright © 2019 Joseph Pereniguez. All rights reserved.
//

import Foundation

extension Float {
    var clean: String {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
