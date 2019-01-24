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
        
        TWTRTwitter.sharedInstance().start(withConsumerKey: "sANCETJynukAwPblwMice7q3n", consumerSecret: "xX1c1rgay55DSUoAYooBBCvRznhBpri7SwzAKxl3W6VP2sZ6FV")
        
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
            print("An error occured during Google Authentication")
            return
        }
        
        // get the credentials
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if (error) != nil {
                print("Google Authentification Fail")
            } else {
                print("Google Authentification Success")
                let user = Auth.auth().currentUser
                
                // define the database structure
                let userData: [String: Any] = [
                    "name": user?.displayName as Any,
                    "email": user?.email as Any
                ]
                
                self.ref = Database.database().reference()
                // push the user datas on the database
                guard let uid = authResult?.user.uid else { return }
                self.ref.child("users/\(uid)").setValue(userData)
                
                // access to the homeviewcontroller
                let mainStoryBoard: UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
                let protectedPage = mainStoryBoard.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
                protectedPage.selectedViewController = protectedPage.viewControllers?[1]
                let appDelegate = UIApplication.shared.delegate
                appDelegate?.window??.rootViewController = protectedPage
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
}

