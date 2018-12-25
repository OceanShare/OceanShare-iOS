//
//  UIButtonExtensions.swift
//  OceanShare
//
//  Created by Hugo Lackermaier on 27/11/2018.
//  Copyright © 2018 Hugo Lackermaier. All rights reserved.
//

import Foundation
import UIKit

class GenericButton: UIButton {
    
    convenience init(Text: String, FontSize: CGFloat, BackgroundColor: UIColor, TitleColor: UIColor,CornerRadius: CGFloat) {
        self.init()
        self.backgroundColor = BackgroundColor
        self.setTitleColor(TitleColor, for: .normal)
        self.setTitle(Text, for: .normal)
        self.titleLabel!.font = UIFont(name: "Helvetica", size: FontSize)
        self.titleLabel!.font = UIFont.boldSystemFont(ofSize: FontSize)
        self.layer.cornerRadius = CornerRadius
        self.clipsToBounds = true
    }
}

extension GenericButton {
    
    func setupConstraints(leading: CGFloat, trailing: CGFloat, y: CGFloat, height: CGFloat, view: UIView) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leading).isActive = true
        self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: trailing).isActive = true
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
        self.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: y).isActive = true
    }
}
