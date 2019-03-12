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
import FirebaseStorage
import FirebaseCore
import GoogleSignIn
import FBSDKLoginKit
import TwitterKit
import TwitterCore_Private
import Alamofire

class LoginViewController: UIViewController, GIDSignInUIDelegate {
    
    // MARK: outlets
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var email: UIImageView!
    @IBOutlet weak var password: UIImageView!
    
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK: definitions
    
    var ref: DatabaseReference!
    let storageRef = FirebaseStorage.Storage().reference()
    
    var imageURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        observeKeyboardNotification()
        
        ref = Database.database().reference()
        
        setupView()
    }
    
    // MARK: setup
    
    func setupView() {
        let color1 = UIColor(rgb: 0x57A1FF)
        let color2 = UIColor(rgb: 0x6dd5ed)
        self.loginButton.applyGradient(colours:[color1, color2], corner:27.5)
        
        self.background.layer.cornerRadius = 16
        self.background.clipsToBounds = true
        
        self.email.image = self.email.image!.withRenderingMode(.alwaysTemplate)
        self.email.tintColor = UIColor(rgb: 0xFFFFFF)
        self.password.image = self.password.image!.withRenderingMode(.alwaysTemplate)
        self.password.tintColor = UIColor(rgb: 0xFFFFFF)
    }
    
    // MARK: actions
    
    @IBAction func forgotHandler(_ sender: UIButton) {
        
        let email = emailTextField.text
        
        if (email?.isEmpty)! {
            displayMessage(userMessage: "You need to fill the email field.")
            return
        }
        sendPasswordReset(withEmail: email!)
        let alert = UIAlertController(title: "Please Check Your Emails.", message: "You probably recieved a mail from us to help you finding a new password.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Send me an other mail.", style: .default, handler: { action in
            self.sendPasswordReset(withEmail: email!)
            print("~ Action Informations: An Other Mail Has Been Sent.")
        }))
        alert.addAction(UIAlertAction(title: "I'll check my emails", style: .default, handler: { action in
            print("~ Action Information: OK Pressed.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // login with email
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let err = error {
                print("(1) Email Authentication Failed: ", err.localizedDescription)
                
                // error handling
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                // check if the user has confirmed its email address
                if (Auth.auth().currentUser?.isEmailVerified == true) {
                    // access to the homeviewcontroller
                    print("-> Email Authentication Success.")
                    let mainTabBarController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
                    mainTabBarController.selectedViewController = mainTabBarController.viewControllers?[1]
                    self.present(mainTabBarController, animated: true,completion: nil)
                    
                } else {
                    // handle the email confirmation
                    let alert = UIAlertController(title: "Please Confirm Your Email.", message: "You need to confirm your email address to finish your inscription and access to your profile.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Send me an other mail.", style: .default, handler: { action in
                        self.sendEmailVerification()
                        print("~ Action Informations: An Other Mail Has Been Sent.")
                    }))
                    alert.addAction(UIAlertAction(title: "I'll check my emails", style: .default, handler: { action in
                        print("~ Action Information: OK Pressed.")
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    // login with facebook
    @IBAction func facebookLogin(sender: AnyObject){
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self, handler:{(facebookResult, facebookError) -> Void in
            if facebookError != nil {
                print("(1) Facebook login failed : \(String(describing: facebookError)).")
            } else if facebookResult!.isCancelled {
                print("(0) Facebook login was cancelled.")
            } else {
                // get the credentials
                let accessToken = FBSDKAccessToken.current()
                guard let accessTokenString = accessToken?.tokenString else { return }
                let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
                
                // get user datas from the facebook account as the profile picture
                FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email, picture.type(large)"]).start(completionHandler: { (connection, result, err) in
                    if err != nil {
                        print("(2) Facebook Authentication Failed: ", err as Any)
                        return
                    }
                    
                    // retrieve user profile picture from facebook
                    let field = result! as? [String: Any]
                    if let retrievedURL = ((field!["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                        // set the value of the retrieved picture
                        self.imageURL = retrievedURL
                    }
                    
                    Auth.auth().signInAndRetrieveData(with: credentials, completion: { (authResult, err) in
                        if let err = err {
                            print("(3) Facebook Authentication Failed: ", err)
                            return
                        }
                        let user = Auth.auth().currentUser
                        
                        // define the database structure and upload the profile picture from facebook
                        let userData: [String: Any] = [
                            "name": user?.displayName as Any,
                            "email": user?.email as Any,
                            "picture": self.imageURL as Any
                        ]
                        
                        // push the user datas on the database
                        guard let uid = authResult?.user.uid else { return }
                        self.ref.child("users/\(uid)").setValue(userData)
                    })
                })
                print("-> Facebook Authentication Success.")
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
    
    fileprivate func configureTwitter() {
        let twitterSignInButton = TWTRLogInButton(logInCompletion: { session, error in
            if (error != nil) {
                print("(1) Twitter Authentication Failed: ", error!.localizedDescription)
            } else {
                // get the twitter credentials
                guard let token = session?.authToken else {return}
                guard let secret = session?.authTokenSecret else {return}
                let credential = TwitterAuthProvider.credential(withToken: token, secret: secret)
                
                Auth.auth().signInAndRetrieveData(with: credential, completion: { (authResult, err) in
                    if let err = err {
                        print("(2) Twitter Authentication Failed: ", err.localizedDescription)
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
                        print("-> Twitter Authentication Success.")
                        let mainTabBarController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
                        mainTabBarController.selectedViewController = mainTabBarController.viewControllers?[1]
                        self.present(mainTabBarController, animated: true,completion: nil)
                    }
                })
            }
        })
        // hide the true and unconfigurable twitter button
        twitterSignInButton.frame = CGRect(x: 300, y: 200, width: 73, height: 65)
        view.addSubview(twitterSignInButton)
        twitterSignInButton.isHidden = true
        twitterSignInButton.accessibilityActivate()
    }
    
    // MARK: error handling
    
    func displayMessage(userMessage:String) -> Void {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Please Fill The Fields Correctly.", message: userMessage, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                /*DispatchQueue.main.async {
                 self.dismiss(animated: true, completion: nil)
                 }*/
                print("~ Actions Information: OK Pressed.")
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion:nil)
        }
    }
    
    // MARK: email handling
    
    func sendEmailVerification(_ callback: ((Error?) -> ())? = nil){
        Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
            callback?(error)
        })
    }
    
    func sendPasswordReset(withEmail email: String, _ callback: ((Error?) -> ())? = nil){
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            callback?(error)
        }
    }
    
    // MARK: keyboard handling
    
    fileprivate func observeKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardShow() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.frame = CGRect(x: 0, y: -100, width: self.view.frame.width, height: self.view.frame.height)
            
        }, completion: nil)
    }
    
    @objc func keyboardHide() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            
        }, completion: nil)
    }
    
}
