//
//  AppDelegate.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 25/12/2018.
//  Copyright © 2018 Joseph Pereniguez. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import FirebaseDatabase
import Stripe

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?
    var ref: DatabaseReference!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        STPPaymentConfiguration.shared().publishableKey = "pk_test_aKG5XmyrMWd17loRBt4W45Vd00nDvn7UF1"
        Stripe.setDefaultPublishableKey("pk_test_aKG5XmyrMWd17loRBt4W45Vd00nDvn7UF1")
        
        FirebaseApp.configure()
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let googleAuthentication = GIDSignIn.sharedInstance().handle(url)
        
        let facebookAuthentication = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        
        
        return facebookAuthentication || googleAuthentication
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    // MARK: - Authentication
    
    /**
     - Description - Sign in or signup the user with a Google account.
     - Inputs - signIn `GIDSignIn` & user `GIDGoogleUser` & error `Error`
     */
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error) != nil {
            print("(1) Google Authentification Failed: ", error!)
            return
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential, completion: { (authResult, error) in
            if (error) != nil {
                print("(2) Google Authentification Failed: ", error as Any)
            } else {
                let user = Auth.auth().currentUser
                
                let refToCheck = Database.database().reference().child("users")
                
                refToCheck.child(user!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.hasChild("email") {
                        print("-> Google user has already set its data.")
                        Defaults.feedDefault(uid: user!.uid, isEmail: false)
                    } else {
                        let userPreferencesData: [String: Any] = [
                            "ghost_mode": false as Bool,
                            "show_picture": false as Bool,
                            "boatId": 1 as Int,
                            "user_active": true as Bool
                        ]
                        // define the database structure
                        let userData: [String: Any] = [
                            "name": user?.displayName as Any,
                            "email": user?.email as Any,
                            "ship_name": "" as String,
                            "preferences": userPreferencesData as [String: Any]
                        ]
                        
                        self.ref = Database.database().reference()
                        // push the user datas on the database
                        guard let uid = authResult?.user.uid else { return }
                        self.ref.child("users/\(uid)").setValue(userData)
                        _ = Defaults.save(uid, name: (user?.displayName)!, email: (user?.email)!, picture: "", shipName: "", boatId: 1, ghostMode: false, showPicture: false, isEmail: false, isCelsius: true, subEnd: NSDate() as Date)
                    }
                })

                print("-> Google Authentication Success.")
                // set the userdefaults data
                UserDefaults.standard.set(Auth.auth().currentUser?.uid, forKey: "user_uid_key")
                // access to the homeviewcontroller
                let mainStoryBoard: UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
                let protectedPage = mainStoryBoard.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
                protectedPage.selectedViewController = protectedPage.viewControllers?[0]
                let appDelegate = UIApplication.shared.delegate
                appDelegate?.window??.rootViewController = protectedPage
            }
        })
    }
    
    /**
     - Description - Log out the user from the app.
     - Inputs - signIn `GIDSignIn` & user `GIDGoogleUser` & error `Error`
     */
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            if Auth.auth().currentUser == nil {
                UserDefaults.standard.removeObject(forKey: "user_uid_key")
                Defaults.clearUserData()
            }
        } catch let signOutError as NSError {
            print ("(1) Error While Signing Out: %@", signOutError)
        }
    }
}

