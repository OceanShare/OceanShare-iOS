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
    var ref: DatabaseReference!
    var imageURL: String?
    var currentTappedTextField : UITextField?
    let storageRef = Storage.storage().reference()
    let registry = Registry()
    
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

    // MARK: - ViewDidLoad
    
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
        signUpButton.applyGradient(colours:[color1, color2], corner:27.5)
        background.layer.cornerRadius = 16
        background.clipsToBounds = true
        setupLocalizedStrings()
        setupCustomIcons()
        
    }

    /**
    - Description - Setup icon design.
    */
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
    
    /**
    - Description - Setup the translated labels.
    */
    func setupLocalizedStrings() {
        signupTitle.text = NSLocalizedString("signupTitle", comment: "")
        usernameTitle.text = NSLocalizedString("usernameTitle", comment: "")
        emailTitle.text = NSLocalizedString("emailTitle", comment: "")
        passwordTitle.text = NSLocalizedString("passwordTitle", comment: "")
        confirmTitle.text = NSLocalizedString("confirmTitle", comment: "")
        signUpButton.setTitle(NSLocalizedString("signupButton", comment: ""), for: .normal)
        signinButton.setTitle(NSLocalizedString("signinFromRegister", comment: ""), for: .normal)
        
    }
    
    // MARK: - Signup functions
    
    /**
    - Description - Present the `HomeViewController` when the user is logged.
    */
    func redirectToHome() {
        let mainTabBarController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
        mainTabBarController.selectedViewController = mainTabBarController.viewControllers?[0]
        self.present(mainTabBarController, animated: true,completion: nil)
        
    }
    
    /**
     - Description - Signup using an email account.
     */
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
                    print(err.localizedDescription)
                    /* error handling */
                    let alert = UIAlertController(title: NSLocalizedString("error", comment: ""), message: err.localizedDescription, preferredStyle: .alert)
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
                    _ = Defaults.save(uid, name: name!, email: email!, picture: "", shipName: "", boatId: 1, ghostMode: false, showPicture: false, isEmail: true, isCelsius: true)
                    self.redirectToHome()
                    User.sendEmailVerification()
                    
                }
            }
        }
    }
    
    /**
     - Description - Signup using a Facebook account.
     */
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
                                _ = Defaults.save(uid, name: (user?.displayName)!, email: (user?.email)!, picture: self.imageURL ?? "", shipName: "", boatId: 1, ghostMode: false, showPicture: false, isEmail: true, isCelsius: true)
                            }
                        })
                    })
                })
                print("-> Facebook Authentication Success.")
                self.redirectToHome()
            }
        })
    }
    
    /**
     - Description - Signup using a Google account.
     */
    @IBAction func googleLogin(_ sender: Any) {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
        
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
            
            self.view.frame = CGRect(x: 0, y: -200, width: self.view.frame.width, height: self.view.frame.height)
            
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
