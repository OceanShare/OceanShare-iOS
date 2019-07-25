//
//  RootViewController.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 26/12/2018.
//  Copyright © 2018 Joseph Pereniguez. All rights reserved.
//

import UIKit
import FirebaseAuth

class RootViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    let registry = Registry()
    var pageControl = UIPageControl()
    
    // list the view controller from the root view controller
    lazy var viewControllerList:[UIViewController] = {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc1 = sb.instantiateViewController(withIdentifier: "StartViewController")
        let vc2 = sb.instantiateViewController(withIdentifier: "LoginViewController")
        let vc3 = sb.instantiateViewController(withIdentifier: "SignupViewController")
        return [vc1, vc2, vc3]
    }()
    
    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // define the Firebase variable
        dataSource = self
        delegate = self
        // define the first view of the RootViewController
        if let firstViewController = viewControllerList.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
        // apply the design stuff to the view
        configurePageControl()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // check if the user is already logged in
        if UserDefaults.standard.object(forKey: "user_uid_key") != nil {
            print("-> User already logged.")
            
            if UserDefaults.standard.object(forKey : "user_logged_by_email") != nil {
                print("-> User logged by email.")
                
                // check if the user has confirmed its email address
                if (Auth.auth().currentUser?.isEmailVerified == true) {
                    print("-> Email already validated and user re-logged.")
                    // set the userdefaults data
                    UserDefaults.standard.set(Auth.auth().currentUser?.uid, forKey: "user_uid_key")
                    UserDefaults.standard.set("yes", forKey: "user_logged_by_email")
                    UserDefaults.standard.synchronize()
                    // access to the homeviewcontroller
                    let mainTabBarController = storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
                    mainTabBarController.selectedViewController = mainTabBarController.viewControllers?[0]
                    present(mainTabBarController, animated: true,completion: nil)
                    
                } else {
                    print("-> Email not validated yet or user not re-logged yet.")
                    // handle the email confirmation
                    let alert = UIAlertController(title: "Please Confirm Your Email.", message: "You need to confirm your email address to finish your inscription and access to your profile.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Send me an other mail.", style: .default, handler: { action in
                        self.sendEmailVerification()
                        print("~ Action Informations: An Other Mail Has Been Sent.")
                    }))
                    alert.addAction(UIAlertAction(title: "Already done, login.", style: .default, handler: { action in
                        // redirect the user to the map
                        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier:   "LoginViewController") as! LoginViewController
                        self.present(loginViewController, animated: true,completion: nil)
                        print("~ Action Information: OK Pressed.")
                    }))
                    present(alert, animated: true, completion: nil)
                    
                }
            } else {
                
                print("-> User logged bu social networks.")
                
                // redirect the user to the map
                let mainTabBarController = storyboard?.instantiateViewController(withIdentifier:   "MainTabBarController") as! MainTabBarController
                mainTabBarController.selectedViewController = mainTabBarController.viewControllers?[0]
                present(mainTabBarController, animated: true,completion: nil)
                
            }
        }
    }
    
    // MARK: - Setup
    
    func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 50,width: UIScreen.main.bounds.width,height: 50))
        pageControl.numberOfPages = viewControllerList.count
        pageControl.currentPage = 0
        pageControl.tintColor = registry.customBlack
        pageControl.pageIndicatorTintColor = registry.customDarkGrey
        pageControl.currentPageIndicatorTintColor = registry.customClearBlue
        pageControl.layer.position.y = view.frame.height - 75
        view.addSubview(pageControl)
    }
    
    // MARK: - Datasource Functions
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = viewControllerList.firstIndex(of: viewController) else { return nil }
        let previousIndex = vcIndex - 1
        guard previousIndex >= 0 else { return nil }
        guard viewControllerList.count > previousIndex else { return nil }
        return viewControllerList[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = viewControllerList.firstIndex(of: viewController) else { return nil }
        let nextIndex = vcIndex + 1
        guard viewControllerList.count != nextIndex else { return nil }
        guard viewControllerList.count > nextIndex else { return nil }
        return viewControllerList[nextIndex]
    }
    
    // MARK: - Delegate Methods

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        pageControl.currentPage = viewControllerList.firstIndex(of: pageContentViewController)!
    }
    
    // MARK: - Email Verification
    
    func sendEmailVerification(_ callback: ((Error?) -> ())? = nil){
        Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
            callback?(error)
        })
    }
    
}
