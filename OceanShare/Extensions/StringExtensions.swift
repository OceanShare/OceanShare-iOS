//
//  StringExtensions.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 31/10/2019.
//  Copyright © 2019 Joseph Pereniguez. All rights reserved.
//

import Foundation

extension String {
    func toDouble() -> Double? {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "en_US_POSIX")
        return numberFormatter.number(from: self)?.doubleValue
    }
}
