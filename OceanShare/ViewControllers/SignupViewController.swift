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
import GoogleSignIn
import FBSDKLoginKit
import TwitterKit
import Alamofire

class SignupViewController: UIViewController, GIDSignInUIDelegate {
    
    // MARK: outlets
    
    @IBOutlet weak var NameTextField: UITextField!
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var ConfirmTextField: UITextField!
    @IBOutlet weak var name: UIImageView!
    @IBOutlet weak var email: UIImageView!
    @IBOutlet weak var password: UIImageView!
    @IBOutlet weak var confirm: UIImageView!
    
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var SignUpButton: UIButton!
    
    // MARK: definitions
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        setupView()
    }
    
    // MARK: setup
    
    func setupView() {
        let color1 = UIColor(rgb: 0x57A1FF)
        let color2 = UIColor(rgb: 0x6dd5ed)
        self.SignUpButton.applyGradient(colours:[color1, color2], corner:27.5)
        
        self.background.layer.cornerRadius = 16
        self.background.clipsToBounds = true
        
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
        twitterSignInButton.frame = CGRect(x: 300, y: 200, width: 73, height: 65)
        view.addSubview(twitterSignInButton)
        twitterSignInButton.isHidden = true
        twitterSignInButton.accessibilityActivate()
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
