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
import TwitterKit

class LoginViewController: UIViewController, GIDSignInUIDelegate {
    
    // MARK: outlets
    
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var FacebookLogin: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureGoogleSignInButton()
        configureFacebookSignInButton()
        configureTwitterSignInButton()
    }
    
    // MARK: actions
    
    // login with email
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
                let mainTabBarController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
                mainTabBarController.selectedViewController = mainTabBarController.viewControllers?[1]
                self.present(mainTabBarController, animated: true,completion: nil)
            }
        }
    }
    
    // login with facebook
    @IBAction func facebookLogin (sender: AnyObject){
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logIn(withReadPermissions: ["email"], from: self, handler:{(facebookResult, facebookError) -> Void in
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            } else if facebookResult!.isCancelled {
                print("Facebook login was cancelled.")
            } else {
                let mainTabBarController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
                mainTabBarController.selectedViewController = mainTabBarController.viewControllers?[1]
                self.present(mainTabBarController, animated: true,completion: nil)
                print("User Logged in successfully by Facebook.")
                
            }
        });
    }

    // MARK: google, facebook and twitter login
    
    // google button configuration
    fileprivate func configureGoogleSignInButton() {
        let googleSignInButton = GIDSignInButton()
        googleSignInButton.frame = CGRect(x: 10, y: 200, width: 40, height: 50)
        view.addSubview(googleSignInButton)
        GIDSignIn.sharedInstance().uiDelegate = self
        googleSignInButton.layer.position.y = self.view.frame.height - 220
    }
    
    // Facebook button configuration
    fileprivate func configureFacebookSignInButton() {
        self.FacebookLogin.frame = CGRect(x: 128, y: 200, width: 75, height: 40)
        self.FacebookLogin.layer.position.y = self.view.frame.height - 220
    }
    
    // Twitter button configuration
    fileprivate func configureTwitterSignInButton() {
        let twitterSignInButton = TWTRLogInButton(logInCompletion: { session, error in
            if (error != nil) {
                print("Twitter authentication failed")
            } else {
                guard let token = session?.authToken else {return}
                guard let secret = session?.authTokenSecret else {return}
                let credential = TwitterAuthProvider.credential(withToken: token, secret: secret)
                Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in // change
                    if error == nil {
                        let mainTabBarController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
                        mainTabBarController.selectedViewController = mainTabBarController.viewControllers?[1]
                        self.present(mainTabBarController, animated: true,completion: nil)
                        print("Twitter authentication succeed")
                    } else {
                        print("Twitter authentication failed")
                    }
                }
            }
        })
        
        twitterSignInButton.frame = CGRect(x: 204, y: 200, width: 200, height: 40)
        view.addSubview(twitterSignInButton)
        twitterSignInButton.layer.position.y = self.view.frame.height - 220
    }
    
}
