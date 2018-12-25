//
//  UILabelExtensions.swift
//  OceanShare
//
//  Created by Hugo Lackermaier on 26/11/2018.
//  Copyright © 2018 Hugo Lackermaier. All rights reserved.
//

import Foundation
import UIKit

class GenericLabel: UILabel {
    
    convenience init(Text: String, FontSize: CGFloat, Color: UIColor) {
        self.init()
        
        self.text = Text
        self.font = UIFont(name: "Helvetica", size: FontSize)
        self.textColor = Color
    }
}

extension GenericLabel {
    
    func setupConstraints(leading: CGFloat, trailing: CGFloat, y: CGFloat, view: UIView) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leading).isActive = true
        self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: trailing).isActive = true
        self.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: y).isActive = true
    }
}
