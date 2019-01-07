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
    @IBOutlet weak var email: UIImageView!
    @IBOutlet weak var password: UIImageView!
    
    @IBOutlet weak var GoogleIcon: UIButton!
    @IBOutlet weak var FacebookIcon: UIButton!
    @IBOutlet weak var TwitterIcon: UIButton!
    @IBOutlet weak var BlueBackground: UIImageView!
    @IBOutlet weak var ForgotButton: UIButton!
    @IBOutlet weak var LoginButton: UIButton!
    
    // MARK: definitions
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        setupIcons()
        setupShadows()
    }
    
    // MARK: setup
    
    func setupShadows() {
        self.BlueBackground.layer.shadowColor = UIColor.black.cgColor
        self.BlueBackground.layer.shadowOpacity = 0.3
        self.BlueBackground.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        self.BlueBackground.layer.shadowRadius = 5.0
        
        self.ForgotButton.layer.shadowColor = UIColor.black.cgColor
        self.ForgotButton.layer.shadowOpacity = 0.3
        self.ForgotButton.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.ForgotButton.layer.shadowRadius = 5.0
        
        self.GoogleIcon.layer.shadowColor = UIColor.black.cgColor
        self.GoogleIcon.layer.shadowOpacity = 0.3
        self.GoogleIcon.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        self.GoogleIcon.layer.shadowRadius = 5.0
        
        self.FacebookIcon.layer.shadowColor = UIColor.black.cgColor
        self.FacebookIcon.layer.shadowOpacity = 0.3
        self.FacebookIcon.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        self.FacebookIcon.layer.shadowRadius = 5.0
        
        self.TwitterIcon.layer.shadowColor = UIColor.black.cgColor
        self.TwitterIcon.layer.shadowOpacity = 0.3
        self.TwitterIcon.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        self.TwitterIcon.layer.shadowRadius = 5.0
        
        self.LoginButton.layer.shadowColor = UIColor.black.cgColor
        self.LoginButton.layer.shadowOpacity = 0.3
        self.LoginButton.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        self.LoginButton.layer.shadowRadius = 5.0
    }
    
    func setupIcons() {
        self.email.image = self.email.image!.withRenderingMode(.alwaysTemplate)
        self.email.tintColor = UIColor(rgb: 0xFFFFFF)
        self.password.image = self.password.image!.withRenderingMode(.alwaysTemplate)
        self.password.tintColor = UIColor(rgb: 0xFFFFFF)
    }
    
    // MARK: actions
    
    
    @IBAction func ForgotHandler(_ sender: UIButton) {
        print("Todo")
        return
    }
    
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
    
    // login with facebook
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
    
    // login with google
    @IBAction func googleLogin(_ sender: Any) {
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    // login with twitter
    @IBAction func twitterLogin(_ sender: UIButton) {
        configureTwitter()
    }

    // MARK: configuration
    
    fileprivate func configureTwitter() {
        let twitterSignInButton = TWTRLogInButton(logInCompletion: { session, error in
            if (error != nil) {
                print("Twitter authentication failed: ", error!.localizedDescription)
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
        twitterSignInButton.frame = CGRect(x: 300, y: 200, width: 73, height: 65)
        view.addSubview(twitterSignInButton)
        twitterSignInButton.isHidden = true
        twitterSignInButton.accessibilityActivate()
    }
    
}
