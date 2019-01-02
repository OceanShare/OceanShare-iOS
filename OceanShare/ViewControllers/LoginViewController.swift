//
//  LoginViewController.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 26/12/2018.
//  Copyright © 2018 Joseph Pereniguez. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass
import FirebaseAuth
import GoogleSignIn
import FBSDKLoginKit

class LoginViewController: UIViewController, GIDSignInUIDelegate {
    
    // MARK: outlets
    
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureGoogleSignInButton()
        configureFacebookSignInButton()
    }
    
    // MARK: actions
    
    @IBAction func LoginButtonTapped(_ sender: UIButton) {
        
        guard let email = EmailTextField.text else { return }
        guard let password = PasswordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let err = error {
                print(err.localizedDescription)
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                print("User has logged in successfully.")
                //let homeView = UINavigationController(rootViewController: HomeViewController())
                let mainTabBarController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
                mainTabBarController.selectedViewController = mainTabBarController.viewControllers?[1]
                self.present(mainTabBarController, animated: true,completion: nil)
            }
        }
    }
    
    @IBAction func ForgotButtonTapped(_ sender: UIButton) {
        // add forgot password function
    }
    
    @IBAction func SignupButtonTapped(_ sender: UIButton) {
        // show signup view controller
    }
    
    // MARK: google & facebook login
    
    fileprivate func configureGoogleSignInButton() {
        
        let googleSignInButton = GIDSignInButton()
        googleSignInButton.frame = CGRect(x: 200, y: 200, width: 40, height: 50)
        view.addSubview(googleSignInButton)
        GIDSignIn.sharedInstance().uiDelegate = self
        googleSignInButton.layer.position.y = self.view.frame.height - 220 ;
    }
    
    fileprivate func configureFacebookSignInButton() {
        
        let facebookSignInButton = FBSDKLoginButton()
        facebookSignInButton.frame = CGRect(x: 120, y: 200, width: 75, height: 40)
        view.addSubview(facebookSignInButton)
        facebookSignInButton.delegate = self as? FBSDKLoginButtonDelegate
        facebookSignInButton.layer.position.y = self.view.frame.height - 220 ;
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if error == nil {
            print("User just logged in via Facebook")
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            
            Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                if (error != nil) {
                    print("Facebook authentication failed")
                    
                } else {
                    print("Facebook authentication succeed")
                    
                }
            }
            
        } else {
            print("An error occured the user couldn't log in")
            
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("User just logged out from his Facebook account")
    }
    
}
