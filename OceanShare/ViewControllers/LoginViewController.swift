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
    
    // MARK: - Variables
    
    var ref: DatabaseReference!
    var imageURL: String?
    
    let storageRef = Storage.storage().reference()
    let registry = Registry()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        overrideUserInterfaceStyle = .light
        ref = Database.database().reference()
        setupView()
        
    }
    
    // MARK: - Setup
    
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
    
    func setupLocalizedStrings() {
        loginTitle.text = NSLocalizedString("loginTitle", comment: "")
        emailLabel.text = NSLocalizedString("emailLabel", comment: "")
        passwordLabel.text = NSLocalizedString("passwordLabel", comment: "")
        forgotButton.setTitle(NSLocalizedString("forgotButton", comment: ""), for: .normal)
        loginButton.setTitle(NSLocalizedString("loginButton", comment: ""), for: .normal)
        registerButton.setTitle(NSLocalizedString("registerFromLogin", comment: ""), for: .normal)
        
    }
    
    func setupCustomIcons() {
        emailImage.image = emailImage.image!.withRenderingMode(.alwaysTemplate)
        emailImage.tintColor = registry.customWhite
        passwordImage.image = passwordImage.image!.withRenderingMode(.alwaysTemplate)
        passwordImage.tintColor = registry.customWhite
        
    }
    
    // MARK: - Email Login
    
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
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let err = error {
                print("(1) Email Authentication Failed: ", err.localizedDescription)
                /* error handling */
                let alertController = UIAlertController(title: NSLocalizedString("error", comment: ""), message: NSLocalizedString("wrongPassword", comment: ""), preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                /* check if the user has confirmed its email address */
                if (Auth.auth().currentUser?.isEmailVerified == true) {
                    print("-> Email Authentication Success.")
                    Defaults.feedDefault(uid: Auth.auth().currentUser!.uid, isEmail: true)
                    /* access to the homeviewcontroller */
                    let mainTabBarController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
                    mainTabBarController.selectedViewController = mainTabBarController.viewControllers?[0]
                    self.present(mainTabBarController, animated: true,completion: nil)
                    
                } else {
                    /* handle the email confirmation */
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
    
    // MARK: - Facebook Login
    
    @IBAction func facebookLogin(sender: AnyObject){
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self, handler:{(facebookResult, facebookError) -> Void in
            if facebookError != nil {
                print("Facebook login failed : \(String(describing: facebookError)).")
            } else if facebookResult!.isCancelled {
                print("Facebook login was cancelled.")
            } else {
                /* get the credentials */
                let accessToken = FBSDKAccessToken.current()
                guard let accessTokenString = accessToken?.tokenString else { return }
                let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
                /* get user datas from the facebook account. */
                FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email, picture.type(large)"]).start(completionHandler: { (connection, result, err) in
                    if err != nil {
                        print("(2) Facebook Authentication Failed: ", err as Any)
                        return
                        
                    }
                    /* retrieve user profile picture from facebook */
                    let field = result! as? [String: Any]
                    if let retrievedURL = ((field!["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                        /* set the value of the retrieved picture */
                        self.imageURL = retrievedURL
                        
                    }
                    Auth.auth().signIn(with: credentials, completion: { (authResult, err) in
                        if let err = err {
                            print("(3) Facebook Authentication Failed: ", err)
                            return
                        
                        }
                        let user = Auth.auth().currentUser
                        let refToCheck = Database.database().reference().child("users")
                        
                        refToCheck.child(user!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                            if snapshot.hasChild("email") {
                                print("-> Facebook user has already set its data.")
                                Defaults.feedDefault(uid: user!.uid, isEmail: false)
                            } else {
                                let userPreferencesData: [String: Any] = [
                                    "ghost_mode": false as Bool,
                                    "show_picture": false as Bool,
                                    "boatId": 1 as Int,
                                    "user_active": true as Bool
                                ]
                                /* define the database structure */
                                let userData: [String: Any] = [
                                    "name": user?.displayName as Any,
                                    "email": user?.email as Any,
                                    "picture": self.imageURL as Any,
                                    "ship_name": "" as String,
                                    "preferences": userPreferencesData as [String: Any]
                                ]
                                
                                self.ref = Database.database().reference()
                                /* push the user datas on the database */
                                guard let uid = authResult?.user.uid else { return }
                                self.ref.child("users/\(uid)").setValue(userData)
                                _ = Defaults.save(uid, name: (user?.displayName)!, email: (user?.email)!, picture: self.imageURL ?? "", shipName: "", boatId: 1, ghostMode: false, showPicture: false, isEmail: false, isCelsius: true)
                            }
                        })
                    })
                })
                print("-> Facebook Authentication Success.")
                /* access to the homeviewcontroller */
                let mainTabBarController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
                mainTabBarController.selectedViewController = mainTabBarController.viewControllers?[0]
                self.present(mainTabBarController, animated: true,completion: nil)
            }
        })
    }
    
    // MARK: - Google Login

    @IBAction func googleLogin(_ sender: Any) {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.signIn()
        
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
    
    // MARK: - Keyboard Handling
    
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
