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
import TwitterKit
import FirebaseDatabase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?
    var ref: DatabaseReference!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        TWTRTwitter.sharedInstance().start(withConsumerKey: "jYXRAPhB2S1GDVtZbs57uOtcl", consumerSecret: "nuhpnL3cSEWHIN4ydwjl6nXp9OHu9sWyA5wHxCcpbcYDo0q2Lj")
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let googleAuthentication = GIDSignIn.sharedInstance().handle(url, sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
        
        let facebookAuthentication = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        
        let twitterAuthentication = TWTRTwitter.sharedInstance().application(app, open: url, options: options)
        
        return facebookAuthentication || googleAuthentication || twitterAuthentication
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
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error) != nil {
            print("(1) Google Authentification Failed: ", error!)
            return
        }
        
        // get the credentials
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
                    } else {
                        // define the database structure
                        let userData: [String: Any] = [
                            "name": user?.displayName as Any,
                            "email": user?.email as Any
                        ]
                        
                        self.ref = Database.database().reference()
                        // push the user datas on the database
                        guard let uid = authResult?.user.uid else { return }
                        self.ref.child("users/\(uid)").setValue(userData)
                    }
                })

                print("-> Google Authentication Success.")
                // set the userdefaults data
                UserDefaults.standard.set(Auth.auth().currentUser?.uid, forKey: "user_uid_key")
                UserDefaults.standard.synchronize()
                
                // send an email to the email address mentioned
                self.sendEmailVerification()
                
                // access to the homeviewcontroller
                let mainStoryBoard: UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
                let protectedPage = mainStoryBoard.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
                protectedPage.selectedViewController = protectedPage.viewControllers?[1]
                let appDelegate = UIApplication.shared.delegate
                appDelegate?.window??.rootViewController = protectedPage
            }
        })
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            if Auth.auth().currentUser == nil {
                UserDefaults.standard.removeObject(forKey: "user_uid_key")
                UserDefaults.standard.synchronize()
            }
        } catch let signOutError as NSError {
            print ("(1) Error While Signing Out: %@", signOutError)
        }
    }
    
    // MARK: - Email Verification
    
    func sendEmailVerification(_ callback: ((Error?) -> ())? = nil){
        Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
            callback?(error)
        })
    }
    
}

