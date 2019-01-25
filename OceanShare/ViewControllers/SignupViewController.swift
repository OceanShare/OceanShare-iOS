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
import Alamofire

class SignupViewController: UIViewController, GIDSignInUIDelegate {
    
    // MARK: outlets
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    
    @IBOutlet weak var name: UIImageView!
    @IBOutlet weak var email: UIImageView!
    @IBOutlet weak var password: UIImageView!
    @IBOutlet weak var confirm: UIImageView!
    
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    // MARK: definitions
    
    var ref: DatabaseReference!
    let storageRef = FirebaseStorage.Storage().reference()

    var imageURL: String?
    
    var currentTappedTextField : UITextField?
    //use this method to get tapped textField
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        currentTappedTextField = textField
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        setupView()
    }
    
    // MARK: setup
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    func setupView() {
        // Listen To keyboardsEvent
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
        let color1 = UIColor(rgb: 0x57A1FF)
        let color2 = UIColor(rgb: 0x6dd5ed)
        self.signUpButton.applyGradient(colours:[color1, color2], corner:27.5)
        
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
            Auth.auth().createUserAndRetrieveData(withEmail: email!, password: password!) { (authResult, err) in
                if let err = err {
                    print("X Registration Failed: ", err.localizedDescription)
                    
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
                    
                    // access to the homeviewcontroller
                    print("-> Registration Success.")
                    let mainTabBarController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
                    mainTabBarController.selectedViewController = mainTabBarController.viewControllers?[1]
                    self.present(mainTabBarController, animated: true,completion: nil)
                    
                    // send an email to the email address mentioned
                    self.sendEmailVerification()
                }
            }
        }
    }
    
    // login with facebook
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
                    
                    Auth.auth().signInAndRetrieveData(with: credentials, completion: { (authResult, err) in
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
                // access to the homeviewcontroller
                print("-> Facebook Authentication Success.")
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
    
    @objc func keyboardWillChange(notification: Notification) {
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        /*
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {
            view.frame.origin.y = -keyboardRect.height
        }
        else
        {
            view.frame.origin.y = 0
        }
        */
    }
    
    // MARK: configuration
    
    fileprivate func configureTwitter() {
        let twitterSignInButton = TWTRLogInButton(logInCompletion: { session, error in
            if (error != nil) {
                print("X Twitter authentication failed: ", error!.localizedDescription)
            } else {
                // get the twitter credentials
                guard let token = session?.authToken else {return}
                guard let secret = session?.authTokenSecret else {return}
                let credential = TwitterAuthProvider.credential(withToken: token, secret: secret)
                
                Auth.auth().signInAndRetrieveData(with: credential, completion: { (authResult, err) in
                    if let err = err {
                        print("X Twitter authentication failed: ", err.localizedDescription)
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
    
    // MARK: checks user email
    
    func sendEmailVerification(_ callback: ((Error?) -> ())? = nil){
        Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
            callback?(error)
        })
    }
    
}
