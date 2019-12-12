//
//  DateExtensions.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 12/12/2019.
//  Copyright © 2019 Joseph Pereniguez. All rights reserved.
//

import Foundation

extension Date {
    func addMonth(n: Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .month, value: n, to: self)!
    }
    func addDay(n: Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .day, value: n, to: self)!
    }
    func addSec(n: Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .second, value: n, to: self)!
    }
}
