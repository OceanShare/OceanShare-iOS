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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureGoogleSignInButton()
        configureFacebookSignInButton()
        configureTwitterSignInButton()
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
        googleSignInButton.frame = CGRect(x: 10, y: 200, width: 40, height: 50)
        view.addSubview(googleSignInButton)
        GIDSignIn.sharedInstance().uiDelegate = self
        googleSignInButton.layer.position.y = self.view.frame.height - 220 ;
    }
    
    fileprivate func configureFacebookSignInButton() {
        let facebookSignInButton = FBSDKLoginButton()
        facebookSignInButton.frame = CGRect(x: 128, y: 200, width: 75, height: 40)
        view.addSubview(facebookSignInButton)
        facebookSignInButton.delegate = self as? FBSDKLoginButtonDelegate
        facebookSignInButton.layer.position.y = self.view.frame.height - 220 ;
    }
    
    fileprivate func configureTwitterSignInButton() {
        let twitterSignInButton = TWTRLogInButton(logInCompletion: { session, error in
            if (error != nil) {
                print("Twitter authentication failed")
            } else {
                guard let token = session?.authToken else {return}
                guard let secret = session?.authTokenSecret else {return}
                let credential = TwitterAuthProvider.credential(withToken: token, secret: secret)
                Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
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
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("User just logged out from his Facebook account")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error == nil {
            print("User just logged in via Facebook")
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                if (error != nil) {
                    print("Facebook authentication failed")
                } else {
                    let mainTabBarController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
                    mainTabBarController.selectedViewController = mainTabBarController.viewControllers?[1]
                    self.present(mainTabBarController, animated: true,completion: nil)
                    print("Facebook authentication succeed")
                }
            }
        } else {
            print("An error occured the user couldn't log in")
        }
    }
    
}
