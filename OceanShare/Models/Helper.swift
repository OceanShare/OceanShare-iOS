//
//  Helper.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 04/01/2019.
//  Copyright © 2019 Joseph Pereniguez. All rights reserved.
//

import Foundation
import JJFloatingActionButton
import UIKit

internal struct Helper {
    static func showAlert(for item: JJActionItem) {
        showAlert(title: item.titleLabel.text, message: "Item tapped!")
        print("Item tapped")
    }
    
    static func showAlert(title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    static var rootViewController: UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController
    }
}
