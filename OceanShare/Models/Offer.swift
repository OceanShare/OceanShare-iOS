//
//  Offer.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 29/11/2019.
//  Copyright © 2019 Joseph Pereniguez. All rights reserved.
//

import UIKit
import Foundation

struct Offer {
    let title: String
    let price: String
    
    // MARK: - Functions
    
    /**
     - Description - Fetch all cells from a `UITableViewController` from `Offer` datas.
     - Output - `[Offer]` offer tab
     */
    static func fetchOffer() -> [Offer]  {
        let offerOne = Offer(title: NSLocalizedString("offerOneTitle", comment: ""), price: NSLocalizedString("offerOnePrice", comment: ""))
        let offerTwo = Offer(title: NSLocalizedString("offerTwoTitle", comment: ""), price: NSLocalizedString("offerTwoPrice", comment: ""))
        let offerThree = Offer(title: NSLocalizedString("offerThreeTitle", comment: ""), price: NSLocalizedString("offerThreePrice", comment: ""))
        
        return [offerOne, offerTwo, offerThree]
        
    }
}
