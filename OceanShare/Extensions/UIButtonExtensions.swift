//
//  UIButtonExtensions.swift
//  OceanShare
//
//  Created by Hugo Lackermaier on 27/11/2018.
//  Copyright © 2018 Hugo Lackermaier. All rights reserved.
//

import Foundation
import UIKit

class CustomButton: UIButton {
    
    var shadowLayer: CAShapeLayer!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
            shadowLayer.fillColor = UIColor.white.cgColor
            
            shadowLayer.shadowColor = UIColor.darkGray.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 2.0, height: 2.0)
            shadowLayer.shadowOpacity = 0.8
            shadowLayer.shadowRadius = 2
            
            layer.insertSublayer(shadowLayer, at: 0)
            //layer.insertSublayer(shadowLayer, below: nil) // also works
        }
    }
}

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
