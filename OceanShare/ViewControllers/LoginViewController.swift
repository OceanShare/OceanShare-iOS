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
import Alamofire

class LoginViewController: UIViewController {
    var ref: DatabaseReference!
    var imageURL: String?
    let storageRef = Storage.storage().reference()
    let registry = Registry()
    
    // MARK: - Outlets
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var loginTitle: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailImage: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordImage: UIImageView!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgotButton: DesignableButton!
    @IBOutlet weak var registerButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        ref = Database.database().reference()
        setupView()
        
    }
    
    // MARK: - Setup
    
    /**
    - Description - Setup the design of the view.
    */
    func setupView() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:))))
        observeKeyboardNotification()
        let color1 = registry.customClearBlue
        let color2 = registry.customWhiteBlue
        loginButton.applyGradient(colours:[color1, color2], corner:27.5)
        backgroundImage.layer.cornerRadius = 16
        backgroundImage.clipsToBounds = true
        setupLocalizedStrings()
        setupCustomIcons()
        
    }
    
    /**
    - Description - Setup the translated labels.
    */
    func setupLocalizedStrings() {
        loginTitle.text = NSLocalizedString("loginTitle", comment: "")
        emailLabel.text = NSLocalizedString("emailLabel", comment: "")
        passwordLabel.text = NSLocalizedString("passwordLabel", comment: "")
        forgotButton.setTitle(NSLocalizedString("forgotButton", comment: ""), for: .normal)
        loginButton.setTitle(NSLocalizedString("loginButton", comment: ""), for: .normal)
        registerButton.setTitle(NSLocalizedString("registerFromLogin", comment: ""), for: .normal)
        
    }
    
    /**
    - Description - Setup icon design.
    */
    func setupCustomIcons() {
        emailImage.image = emailImage.image!.withRenderingMode(.alwaysTemplate)
        emailImage.tintColor = registry.customWhite
        passwordImage.image = passwordImage.image!.withRenderingMode(.alwaysTemplate)
        passwordImage.tintColor = registry.customWhite
        
    }
    
    // MARK: - Login functions
    
    /**
     - Description - present the `HomeViewController` when the user is logged.
     */
    func redirectToHome() {
        let mainTabBarController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
        mainTabBarController.selectedViewController = mainTabBarController.viewControllers?[0]
        self.present(mainTabBarController, animated: true,completion: nil)
        
    }
    
    /**
     - Description - Displays an alert if the user forgot its password.
     */
    @IBAction func forgotHandler(_ sender: UIButton) {
        let email = emailTextField.text
        
        if (email?.isEmpty)! {
            displayMessage(userMessage: NSLocalizedString("emailNeeded", comment: ""))
            return
            
        }
        User.sendPasswordReset(withEmail: email!)
        let alert = UIAlertController(title: NSLocalizedString("checkEmailTitle", comment: ""), message: NSLocalizedString("checkEmailMessage", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("sendAnotherMailAction", comment: ""), style: .default, handler: { action in
            User.sendPasswordReset(withEmail: email!)
            print("~ Action Informations: An Other Mail Has Been Sent.")
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("checkMailAction", comment: ""), style: .default, handler: { action in
            print("~ Action Information: OK Pressed.")
        }))
        present(alert, animated: true, completion: nil)
        
    }
    
    /**
     - Description - Handle login using an email account.
     */
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let err = error {
                print(err.localizedDescription)
                let alertController = UIAlertController(title: NSLocalizedString("error", comment: ""), message: NSLocalizedString("wrongPassword", comment: ""), preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                /* Check if the user already has confirmed its email adress. */
                if (Auth.auth().currentUser?.isEmailVerified == true) {
                    Defaults.feedDefault(uid: Auth.auth().currentUser!.uid, isEmail: true)
                    self.redirectToHome()
                    
                } else {
                    let alert = UIAlertController(title: NSLocalizedString("emailNeedsConfirmation", comment: ""), message: NSLocalizedString("emailNeedsConfirmationMessage", comment: ""), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("sendAnotherMailAction", comment: ""), style: .default, handler: { action in
                        User.sendEmailVerification()
                        print("~ Action Informations: An Other Mail Has Been Sent.")
                    }))
                    alert.addAction(UIAlertAction(title: NSLocalizedString("checkMailAction", comment: ""), style: .default, handler: { action in
                        print("~ Action Information: OK Pressed.")
                    }))
                    self.present(alert, animated: true, completion: nil)
                    
                }
            }
        }
    }
    
    /**
     - Description - Handle login using a Facebook account.
     */
    @IBAction func facebookLogin(sender: AnyObject){
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self, handler:{(facebookResult, facebookError) -> Void in
            if facebookError != nil {
                print("\(String(describing: facebookError)).")
                
            } else if facebookResult!.isCancelled {
                print("Facebook login was cancelled.")
                
            } else {
                /* Get the credentials. */
                let accessToken = FBSDKAccessToken.current()
                guard let accessTokenString = accessToken?.tokenString else { return }
                let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
                FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email, picture.type(large)"]).start(completionHandler: { (connection, result, err) in
                    if err != nil {
                        print("(2) Facebook Authentication Failed: ", err as Any)
                        return
                        
                    }
                    /* Retrieve user profile picture from facebook. */
                    let field = result! as? [String: Any]
                    if let retrievedURL = ((field!["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                        /* Set the value of the retrieved picture. */
                        self.imageURL = retrievedURL
                        
                    }
                    Auth.auth().signIn(with: credentials, completion: { (authResult, err) in
                        if let err = err {
                            print(err)
                            return
                        
                        }
                        let user = Auth.auth().currentUser
                        let refToCheck = Database.database().reference().child("users")
                        
                        refToCheck.child(user!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                            /* Check if the user already has an account. */
                            if snapshot.hasChild("email") {
                                Defaults.feedDefault(uid: user!.uid, isEmail: false)
                                
                            } else {
                                let userPreferencesData: [String: Any] = [
                                    "ghost_mode": false as Bool,
                                    "show_picture": false as Bool,
                                    "boatId": 1 as Int,
                                    "user_active": true as Bool
                                ]
                                let userData: [String: Any] = [
                                    "name": user?.displayName as Any,
                                    "email": user?.email as Any,
                                    "picture": self.imageURL as Any,
                                    "ship_name": "" as String,
                                    "preferences": userPreferencesData as [String: Any]
                                ]
                                self.ref = Database.database().reference()
                                guard let uid = authResult?.user.uid else { return }
                                self.ref.child("users/\(uid)").setValue(userData)
                                _ = Defaults.save(uid, name: (user?.displayName)!, email: (user?.email)!, picture: self.imageURL ?? "", shipName: "", boatId: 1, ghostMode: false, showPicture: false, isEmail: false, isCelsius: true)
                            }
                        })
                    })
                })
                self.redirectToHome()
            }
        })
    }

    /**
     - Description - Handle login using a Google account.
     */
    @IBAction func googleLogin(_ sender: Any) {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.signIn()
        
    }
    
    // MARK: - Error Handling
    
    /**
     - Description - Displays a dynamic message.
     - Inputs - userMessage `String`
     - Output - `Void` alert
     */
    func displayMessage(userMessage:String) -> Void {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: NSLocalizedString("defaultErrorMessage", comment: ""), message: userMessage, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action:UIAlertAction!) in
                print("~ Actions Information: OK Pressed.")
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion:nil)
            
        }
    }
    
    // MARK: - Keyboard Handling
    
    /**
     - Description - Handle keyboard when user is typing on a textfield or outside a textfield.
     */
    fileprivate func observeKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    /**
     - Description - Show the keyboard when its needed.
     */
    @objc func keyboardShow() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.frame = CGRect(x: 0, y: -100, width: self.view.frame.width, height: self.view.frame.height)
            
        }, completion: nil)
    }
    
    /**
     - Description - Hide the keyboard when the user is typing outside a textfield.
     */
    @objc func keyboardHide() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            
        }, completion: nil)
    }
}
