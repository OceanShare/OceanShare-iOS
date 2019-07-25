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
import FirebaseStorage
import FirebaseCore
import FirebaseDatabase
import GoogleSignIn
import FBSDKLoginKit
import TwitterKit
import TwitterCore_Private
import Alamofire

class SignupViewController: UIViewController, GIDSignInUIDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var name: UIImageView!
    @IBOutlet weak var email: UIImageView!
    @IBOutlet weak var password: UIImageView!
    @IBOutlet weak var confirm: UIImageView!

    // MARK: - Variables
    
    var ref: DatabaseReference!
    var imageURL: String?
    var currentTappedTextField : UITextField?
    
    let storageRef = FirebaseStorage.Storage().reference()
    let registry = Registry()

    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()

        // apply the design stuff to the view
        setupView()
    }
    
    // MARK: - Setup
    
    func setupView() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:))))
        observeKeyboardNotification()
        // gradient setup
        let color1 = registry.customClearBlue
        let color2 = registry.customWhiteBlue
        signUpButton.applyGradient(colours:[color1, color2], corner:27.5)
        // background setup
        background.layer.cornerRadius = 16
        background.clipsToBounds = true
        // icon setup
        setupCustomIcons()
    }

    func setupCustomIcons() {
        name.image = name.image!.withRenderingMode(.alwaysTemplate)
        name.tintColor = registry.customWhite
        email.image = email.image!.withRenderingMode(.alwaysTemplate)
        email.tintColor = registry.customWhite
        password.image = password.image!.withRenderingMode(.alwaysTemplate)
        password.tintColor = registry.customWhite
        confirm.image = confirm.image!.withRenderingMode(.alwaysTemplate)
        confirm.tintColor = registry.customWhite
    }
    
    // MARK: - Email Registration
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        let name = nameTextField.text
        let email = emailTextField.text
        let password = passwordTextField.text
        
        if (email?.isEmpty)! || (password?.isEmpty)! || (confirmTextField.text?.isEmpty)! || (nameTextField.text?.isEmpty)! {
            displayMessage(userMessage: "All Fields are required.")
            return
            
        }
        if ((confirmTextField.text?.elementsEqual(password!))! != true) {
            displayMessage(userMessage: "Please make sure that passwords match.")
            return
            
        } else {
            // do not care about the warning
            Auth.auth().createUser(withEmail: email!, password: password!) { (authResult, err) in
                if let err = err {
                    print("(1) Registration Failed: ", err.localizedDescription)
                    
                    // error handling
                    let alert = UIAlertController(title: "Error.", message: err.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        print("~ Actions Informations: OK pressed.")
                    }))
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    // define the database structure
                    let userData: [String: Any] = [
                        "name": name as Any,
                        "email": email as Any
                        ]
                    
                    // push the user datas on the database
                    guard let uid = authResult?.user.uid else { return }
                    self.ref.child("users/\(uid)").setValue(userData)
                    
                    print("-> Registration Success.")
                    // set the userdefaults data
                    UserDefaults.standard.set(Auth.auth().currentUser?.uid, forKey: "user_uid_key")
                    UserDefaults.standard.set("yes", forKey: "user_logged_by_email")
                    UserDefaults.standard.synchronize()
                    // access to the homeviewcontroller
                    let mainTabBarController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
                    mainTabBarController.selectedViewController = mainTabBarController.viewControllers?[0]
                    self.present(mainTabBarController, animated: true,completion: nil)
                    
                    // send an email to the email address mentioned
                    self.sendEmailVerification()
                    
                }
            }
        }
    }
    
    // MARK: - Facebook Registration

    @IBAction func facebookLogin(sender: AnyObject){
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self, handler:{(facebookResult, facebookError) -> Void in
            if facebookError != nil {
                print("X Facebook Authentication Failed: \(String(describing: facebookError)).")
                
            } else if facebookResult!.isCancelled {
                print("X Facebook Authentication Was Cancelled.")
                
            } else {
                // get the credentials
                let accessToken = FBSDKAccessToken.current()
                guard let accessTokenString = accessToken?.tokenString else { return }
                let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
                
                // get user datas from the facebook account as the profile picture
                FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email, picture.type(large)"]).start(completionHandler: { (connection, result, err) in
                    if err != nil {
                        print("X Facebook Authentication Failed: ", err as Any)
                        return
                        
                    }
                    
                    // retrieve user profile picture
                    let field = result! as? [String: Any]
                    if let retrievedURL = ((field!["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                        // set the value of the retrieved picture
                        self.imageURL = retrievedURL
                        
                    }
                    
                    Auth.auth().signIn(with: credentials, completion: { (authResult, err) in
                        if let err = err {
                            print("X Facebook Authentication Failed: ", err)
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
                // set the userdefaults data
                UserDefaults.standard.set(Auth.auth().currentUser?.uid, forKey: "user_uid_key")
                UserDefaults.standard.synchronize()
                // access to the homeviewcontroller
                let mainTabBarController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
                mainTabBarController.selectedViewController = mainTabBarController.viewControllers?[0]
                self.present(mainTabBarController, animated: true,completion: nil)
                
            }
        })
    }
    
    // MARK: - Google Registration
    
    @IBAction func googleLogin(_ sender: Any) {
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
        
    }
    
    // MARK: - Twitter Registration
    
    @IBAction func twitterLogin(_ sender: UIButton) {
        configureTwitter()
        
    }
    
    fileprivate func configureTwitter() {
        let twitterSignInButton = TWTRLogInButton(logInCompletion: { session, error in
            if (error != nil) {
                print("(1) Twitter authentication failed: ", error!.localizedDescription)
            
            } else {
                // get the twitter credentials
                guard let token = session?.authToken else {return}
                guard let secret = session?.authTokenSecret else {return}
                let credential = TwitterAuthProvider.credential(withToken: token, secret: secret)
                
                Auth.auth().signIn(with: credential, completion: { (authResult, err) in
                    if let err = err {
                        print("(2) Twitter authentication failed: ", err.localizedDescription)
                    
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
                        
                        print("-> Twitter Authentication Success.")
                        // set the userdefaults data
                        UserDefaults.standard.set(Auth.auth().currentUser?.uid, forKey: "user_uid_key")
                        UserDefaults.standard.synchronize()
                        // access to the homeviewcontroller
                        let mainTabBarController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
                        mainTabBarController.selectedViewController = mainTabBarController.viewControllers?[0]
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
    
    // MARK: - Keyboard Handling
    
    fileprivate func observeKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardShow() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.frame = CGRect(x: 0, y: -200, width: self.view.frame.width, height: self.view.frame.height)
            
        }, completion: nil)
        
    }
    
    @objc func keyboardHide() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            
        }, completion: nil)
        
    }
    
    // use this method to get tapped textField
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        currentTappedTextField = textField
        return true
        
    }
    
    // MARK: - Error Handling
    
    func displayMessage(userMessage:String) -> Void {
        DispatchQueue.main.async {
                let alertController = UIAlertController(title: "Please Fill The Fields Correctly.", message: userMessage, preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    print("~ Actions Information: OK Pressed.")
                }
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion:nil)
        }
    }
    
    // MARK: - Email Verification
    
    func sendEmailVerification(_ callback: ((Error?) -> ())? = nil){
        Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
            callback?(error)
        })
        
    }
    
}
