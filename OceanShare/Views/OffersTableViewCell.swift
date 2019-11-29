//
//  OffersTableViewCell.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 29/11/2019.
//  Copyright © 2019 Joseph Pereniguez. All rights reserved.
//

import Foundation
import UIKit

class OffersTableViewCell: UITableViewCell {
    
    let registry = Registry()
    
    var offer: Offer! {
        didSet {
            updateUI()
            
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var background: DesignableView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var price: UILabel!
    
    // MARK: - Functions
    
    func updateUI() {
        let color1 = registry.customClearBlue
        let color2 = registry.customWhiteBlue
        background.applyGradient(colours:[color1, color2], corner:15)
        title.text = offer.title
        price.text = offer.price
        
    }
}
