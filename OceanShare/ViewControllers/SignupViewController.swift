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
import Alamofire

class SignupViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var signupTitle: UILabel!
    
    @IBOutlet weak var usernameTitle: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var name: UIImageView!
    
    @IBOutlet weak var emailTitle: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var email: UIImageView!
    
    @IBOutlet weak var passwordTitle: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var password: UIImageView!
    
    @IBOutlet weak var confirmTitle: UILabel!
    @IBOutlet weak var confirmTextField: UITextField!
    @IBOutlet weak var confirm: UIImageView!
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signinButton: UIButton!
    
    // MARK: - Variables
    
    var ref: DatabaseReference!
    var imageURL: String?
    var currentTappedTextField : UITextField?
    
    let storageRef = Storage.storage().reference()
    let registry = Registry()

    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        setupView()
        
    }
    
    // MARK: - Setup
    
    func setupView() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:))))
        observeKeyboardNotification()
        let color1 = registry.customClearBlue
        let color2 = registry.customWhiteBlue
        signUpButton.applyGradient(colours:[color1, color2], corner:27.5)
        background.layer.cornerRadius = 16
        background.clipsToBounds = true
        setupLocalizedStrings()
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
    
    func setupLocalizedStrings() {
        signupTitle.text = NSLocalizedString("signupTitle", comment: "")
        usernameTitle.text = NSLocalizedString("usernameTitle", comment: "")
        emailTitle.text = NSLocalizedString("emailTitle", comment: "")
        passwordTitle.text = NSLocalizedString("passwordTitle", comment: "")
        confirmTitle.text = NSLocalizedString("confirmTitle", comment: "")
        signUpButton.setTitle(NSLocalizedString("signupButton", comment: ""), for: .normal)
        signinButton.setTitle(NSLocalizedString("signinFromRegister", comment: ""), for: .normal)
        
    }
    
    // MARK: - Email Registration
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        let name = nameTextField.text
        let email = emailTextField.text
        let password = passwordTextField.text
        
        if (email?.isEmpty)! || (password?.isEmpty)! || (confirmTextField.text?.isEmpty)! || (nameTextField.text?.isEmpty)! {
            displayMessage(userMessage: NSLocalizedString("registerRequiredFields", comment: ""))
            return
            
        }
        if ((confirmTextField.text?.elementsEqual(password!))! != true) {
            displayMessage(userMessage: NSLocalizedString("passwordMatch", comment: ""))
            return
            
        } else {
            Auth.auth().createUser(withEmail: email!, password: password!) { (authResult, err) in
                if let err = err {
                    print("(1) Registration Failed: ", err.localizedDescription)
                    
                    /* error handling */
                    let alert = UIAlertController(title: NSLocalizedString("error", comment: ""), message: err.localizedDescription, preferredStyle: .alert) // TODO
                    alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: { action in
                        print("~ Actions Informations: OK pressed.")
                    }))
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    let userPreferencesData: [String: Any] = [
                        "ghost_mode": false as Bool,
                        "show_picture": false as Bool,
                        "boatId": 1 as Int,
                        "user_active": true as Bool
                    ]
                    let userData: [String: Any] = [
                        "name": name as Any,
                        "email": email as Any,
                        "ship_name": "" as String,
                        "preferences": userPreferencesData as [String: Any]
                        ]
                    guard let uid = authResult?.user.uid else { return }
                    self.ref.child("users/\(uid)").setValue(userData)
                    
                    /* set the userdefaults data */
                    UserDefaults.standard.set(Auth.auth().currentUser?.uid, forKey: "user_uid_key")
                    UserDefaults.standard.set("yes", forKey: "user_logged_by_email")
                    UserDefaults.standard.synchronize()
                    /* access to the homeviewcontroller */
                    let mainTabBarController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
                    mainTabBarController.selectedViewController = mainTabBarController.viewControllers?[0]
                    self.present(mainTabBarController, animated: true,completion: nil)
                    
                    /* send an email to the email address mentioned */
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
                /* get the credentials */
                let accessToken = FBSDKAccessToken.current()
                guard let accessTokenString = accessToken?.tokenString else { return }
                let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
                
                /* get user datas from the facebook account as the profile picture */
                FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email, picture.type(large)"]).start(completionHandler: { (connection, result, err) in
                    if err != nil {
                        print("Facebook Authentication Failed: ", err as Any)
                        return
                        
                    }
                    
                    /* retrieve user profile picture */
                    let field = result! as? [String: Any]
                    if let retrievedURL = ((field!["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                        /* set the value of the retrieved picture */
                        self.imageURL = retrievedURL
                        
                    }
                    
                    Auth.auth().signIn(with: credentials, completion: { (authResult, err) in
                        if let err = err {
                            print("Facebook Authentication Failed: ", err)
                            return
                            
                        }
                        let user = Auth.auth().currentUser
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
                        guard let uid = authResult?.user.uid else { return }
                        
                        self.ref.child("users/\(uid)").setValue(userData)
                        
                    })
                })
                /* set the userdefaults data */
                UserDefaults.standard.set(Auth.auth().currentUser?.uid, forKey: "user_uid_key")
                UserDefaults.standard.synchronize()
                /* access to the homeviewcontroller */
                let mainTabBarController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
                mainTabBarController.selectedViewController = mainTabBarController.viewControllers?[0]
                self.present(mainTabBarController, animated: true,completion: nil)
                
            }
        })
    }
    
    // MARK: - Google Registration
    
    @IBAction func googleLogin(_ sender: Any) {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
        
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
    
    // MARK: - Error Handling
    
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
    
    // MARK: - Email Verification
    
    func sendEmailVerification(_ callback: ((Error?) -> ())? = nil){
        Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
            callback?(error)
        })
        
    }
    
}
