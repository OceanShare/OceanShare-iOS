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
    
    // MARK: definitions
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
    }
    
    // MARK: actions
    
    @IBAction func RegisterButtonTapped(_ sender: UIButton) {
        
        let name = NameTextField.text
        let email = EmailTextField.text
        let password = PasswordTextField.text
        
        // define the database
        let userData: [String: Any] = [
            "name": name,
            "email": email,
            "password": password
        ]
        
        if (email?.isEmpty)! || (password?.isEmpty)! || (ConfirmTextField.text?.isEmpty)! || (NameTextField.text?.isEmpty)! {
            displayMessage(userMessage: "All Field are required")
            return
        }; if ((ConfirmTextField.text?.elementsEqual(password!))! != true) {
            displayMessage(userMessage: "Please make sure that passwords match")
            return
        } else {
            Auth.auth().createUserAndRetrieveData(withEmail: email!, password: password!) { (result, err) in
                if let err = err {
                    print(err.localizedDescription)
                    let alertController = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    guard let uid = result?.user.uid else { return }
                    self.ref.child("users/\(uid)").setValue(userData) // send the data to the Firebase database
                    print("User has been correctly created.")
                    let homeView = UINavigationController(rootViewController: HomeViewController())
                    self.present(homeView, animated: true,completion: nil)
                }
            }
        }
    }
    
    @IBAction func SigninButtonTapped(_ sender: UIButton) {
        // show signin view controller
    }
    
    
    // MARK : functions
    
    func displayMessage(userMessage:String) -> Void {
        DispatchQueue.main.async
            {
                let alertController = UIAlertController(title: "Alert", message: userMessage, preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    // Code in this block will trigger when OK button tapped.
                    print("Ok button tapped")
                    DispatchQueue.main.async
                        {
                            self.dismiss(animated: true, completion: nil)
                    }
                }
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion:nil)
        }
    }
    
}
