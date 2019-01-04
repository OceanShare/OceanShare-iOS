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
import FirebaseDatabase
import GoogleSignIn
import FBSDKLoginKit
import TwitterKit
import Alamofire

class LoginViewController: UIViewController, GIDSignInUIDelegate {
    
    // MARK: outlets
    
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var FacebookLogin: UIButton!
    @IBOutlet weak var GoogleLogin: UIButton!
    @IBOutlet weak var TwitterLogo: UIImageView!
    @IBOutlet weak var GoogleLogo: UIImageView!
    
    // MARK: definitions
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        twitterLogin()
    }
    
    // MARK: actions
    
    // login with email
    @IBAction func LoginButtonTapped(_ sender: UIButton) {
        
        guard let email = EmailTextField.text else { return }
        guard let password = PasswordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let err = error {
                print(err.localizedDescription)
                
                // error handling
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                // access to the homeviewcontroller
                let mainTabBarController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
                mainTabBarController.selectedViewController = mainTabBarController.viewControllers?[1]
                self.present(mainTabBarController, animated: true,completion: nil)
            }
        }
    }
    
    @IBAction func facebookLogin(sender: AnyObject){
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self, handler:{(facebookResult, facebookError) -> Void in
            if facebookError != nil {
                print("Facebook login failed. Error \(String(describing: facebookError))")
            } else if facebookResult!.isCancelled {
                print("Facebook login was cancelled.")
            } else {
                // get the credentials
                let accessToken = FBSDKAccessToken.current()
                guard let accessTokenString = accessToken?.tokenString else { return }
                let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
                
                // get user datas from the facebook account as the profile picture
                FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email, picture.type(large)"]).start(completionHandler: { (connection, result, err) in
                    if err != nil {
                        print("Failed to start graph request.")
                        return
                    }
                    
                    // DO NOT DELETE -> Retrieve user profile picture
                    /*let response = result.unsafelyUnwrapped as! Dictionary<String,AnyObject>
                    let userData: [String: Any] = [
                        "name": response["name"] as? String,
                        "email": response["email"] as? String
                        //"picture": response["picture"]["data"]["url"] as? String
                    ]*/
                    
                    Auth.auth().signInAndRetrieveData(with: credentials, completion: { (authResult, err) in
                        if let err = err {
                            print("Something wrong happened with the FB user: ", err)
                            return
                        }
                        let user = Auth.auth().currentUser
                        
                        // define the database structure
                        let userData: [String: Any] = [
                            "name": user?.displayName as Any,
                            "email": user?.email as Any
                            
                        ]
                        
                        // push the user datas on the database
                        guard let uid = authResult?.user.uid else { return }
                        self.ref.child("users/\(uid)").setValue(userData)
                    })
                })
                // access to the homeviewcontroller
                let mainTabBarController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
                mainTabBarController.selectedViewController = mainTabBarController.viewControllers?[1]
                self.present(mainTabBarController, animated: true,completion: nil)
            }
        })
    }
    
    @IBAction func googleLogin(_ sender: Any) {
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    // MARK: file private functions
    
    fileprivate func twitterLogin() {
        let twitterSignInButton = TWTRLogInButton(logInCompletion: { session, error in
            if (error != nil) {
                print("Twitter authentication failed")
            } else {
                // get the twitter credentials
                guard let token = session?.authToken else {return}
                guard let secret = session?.authTokenSecret else {return}
                let credential = TwitterAuthProvider.credential(withToken: token, secret: secret)
                
                Auth.auth().signInAndRetrieveData(with: credential, completion: { (authResult, err) in
                    if let err = err {
                        print(err.localizedDescription)
                    } else {
                        let user = Auth.auth().currentUser
                        
                        // define the database structure
                        let userData: [String: Any] = [
                            "name": user?.displayName as Any,
                            "email": user?.email as Any
                            
                        ]
                        
                        // push the user datas on the database
                        guard let uid = authResult?.user.uid else { return }
                        self.ref.child("users/\(uid)").setValue(userData)
                        
                        // access to the homeviewcontroller
                        let mainTabBarController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
                        mainTabBarController.selectedViewController = mainTabBarController.viewControllers?[1]
                        self.present(mainTabBarController, animated: true,completion: nil)
                    }
                })
            }
        })
        //Todo: find a way to design the twitter button
        twitterSignInButton.frame = CGRect(x: 300, y: 200, width: 73, height: 65)
        view.addSubview(twitterSignInButton)
        twitterSignInButton.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: twitterSignInButton, attribute: .trailing, relatedBy: .equal, toItem: self.TwitterLogo, attribute: .trailing, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: twitterSignInButton, attribute: .leading, relatedBy: .equal, toItem: self.TwitterLogo, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: twitterSignInButton, attribute: .bottom, relatedBy: .equal, toItem: self.TwitterLogo, attribute: .bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: twitterSignInButton, attribute: .top, relatedBy: .equal, toItem: self.TwitterLogo, attribute: .top, multiplier: 1, constant: 0))
        twitterSignInButton.layer.cornerRadius = 0.5 * twitterSignInButton.bounds.size.width
        twitterSignInButton.clipsToBounds = true
        twitterSignInButton.setImage(UIImage(named:"twitterLogo.png"), for: .normal)
    }
    
}
