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

class CustomView: UIView {
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 100, height: 100)
    }
    
}

class LoginViewController: UIViewController, GIDSignInUIDelegate {
    
    // MARK: outlets
    
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var FacebookLogin: UIButton!
    @IBOutlet weak var TwitterLogo: UIImageView!
    @IBOutlet weak var GoogleLogo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureGoogleSignInButton()
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
        googleSignInButton.frame = CGRect(x: 40, y: 200, width: 73, height: 80)
        view.addSubview(googleSignInButton)
        GIDSignIn.sharedInstance().uiDelegate = self
        googleSignInButton.layer.position.y = self.view.frame.height - 220
        //googleSignInButton.tintColor = UIColor.white.withAlphaComponent(0)
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
        
        twitterSignInButton.frame = CGRect(x: 300, y: 200, width: 73, height: 80)
        view.addSubview(twitterSignInButton)
        twitterSignInButton.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: twitterSignInButton, attribute: .trailing, relatedBy: .equal, toItem: self.TwitterLogo, attribute: .trailing, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: twitterSignInButton, attribute: .leading, relatedBy: .equal, toItem: self.TwitterLogo, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: twitterSignInButton, attribute: .bottom, relatedBy: .equal, toItem: self.TwitterLogo, attribute: .bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: twitterSignInButton, attribute: .top, relatedBy: .equal, toItem: self.TwitterLogo, attribute: .top, multiplier: 1, constant: 0))
    }
    
}
