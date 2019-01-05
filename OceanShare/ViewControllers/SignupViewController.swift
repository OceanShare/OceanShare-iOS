//
//  SignupViewController.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 26/12/2018.
//  Copyright © 2018 Joseph Pereniguez. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass
import FirebaseAuth
import FirebaseDatabase

class SignupViewController: UIViewController {
    
    // MARK: outlets
    
    @IBOutlet weak var NameTextField: UITextField!
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var ConfirmTextField: UITextField!
    @IBOutlet weak var name: UIImageView!
    @IBOutlet weak var email: UIImageView!
    @IBOutlet weak var password: UIImageView!
    @IBOutlet weak var confirm: UIImageView!
    
    // MARK: definitions
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        setupIcons()
    }
    
    // MARK: setup
    
    func setupIcons() {
        self.name.image = self.name.image!.withRenderingMode(.alwaysTemplate)
        self.name.tintColor = UIColor(rgb: 0xFFFFFF)
        self.email.image = self.email.image!.withRenderingMode(.alwaysTemplate)
        self.email.tintColor = UIColor(rgb: 0xFFFFFF)
        self.password.image = self.password.image!.withRenderingMode(.alwaysTemplate)
        self.password.tintColor = UIColor(rgb: 0xFFFFFF)
        self.confirm.image = self.confirm.image!.withRenderingMode(.alwaysTemplate)
        self.confirm.tintColor = UIColor(rgb: 0xFFFFFF)
    }
    
    // MARK: actions
    
    @IBAction func RegisterButtonTapped(_ sender: UIButton) {
        
        let name = NameTextField.text
        let email = EmailTextField.text
        let password = PasswordTextField.text
        
        // define the database structure
        let userData: [String: Any] = [
            "name": name as Any,
            "email": email as Any
        ]
        
        if (email?.isEmpty)! || (password?.isEmpty)! || (ConfirmTextField.text?.isEmpty)! || (NameTextField.text?.isEmpty)! {
            displayMessage(userMessage: "All Field are required")
            return
        }
        if ((ConfirmTextField.text?.elementsEqual(password!))! != true) {
            displayMessage(userMessage: "Please make sure that passwords match")
            return
        } else {
            Auth.auth().createUserAndRetrieveData(withEmail: email!, password: password!) { (authResult, err) in
                if let err = err {
                    print(err.localizedDescription)
                    
                    // error handling
                    let alertController = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    // push the user datas on the database
                    guard let uid = authResult?.user.uid else { return }
                    self.ref.child("users/\(uid)").setValue(userData)
                    
                    // access to the homeviewcontroller
                    let mainTabBarController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
                    mainTabBarController.selectedViewController = mainTabBarController.viewControllers?[1]
                    self.present(mainTabBarController, animated: true,completion: nil)
                }
            }
        }
    }
    
    // MARK : error handling
    
    func displayMessage(userMessage:String) -> Void {
        DispatchQueue.main.async {
                let alertController = UIAlertController(title: "Alert", message: userMessage, preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    // Code in this block will trigger when OK button tapped.
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion:nil)
        }
    }
    
}
