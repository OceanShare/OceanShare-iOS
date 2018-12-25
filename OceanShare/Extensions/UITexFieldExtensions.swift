//
//  UIViewExtensions.swift
//  OceanShare
//
//  Created by Hugo Lackermaier on 05/11/2018.
//  Copyright © 2018 Hugo Lackermaier. All rights reserved.
//

import Foundation
import UIKit

class GenericTextField: UITextField {
    
    convenience init(isEmail: Bool, isPassword: Bool) {
        self.init()
        font = UIFont(name: "Helvetica", size: 15)
        self.textColor = .black
        self.backgroundColor = .white
        self.doneAccessory = true
        self.layer.cornerRadius = 10
        
        if isEmail == true {
            self.keyboardType = UIKeyboardType.emailAddress
        }
        if isPassword == true {
            self.isSecureTextEntry = true
        }
        
    }
}

extension GenericTextField {
    
    func setupConstraints(y: CGFloat, view: UIView) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        self.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: y).isActive = true
    }
}

extension UITextField {
    
    @IBInspectable var doneAccessory: Bool{
        get{
            return self.doneAccessory
        }
        set (hasDone) {
            if hasDone{
                addDoneButtonOnKeyboard()
            }
        }
    }
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction()
    {
        self.resignFirstResponder()
    }
}
