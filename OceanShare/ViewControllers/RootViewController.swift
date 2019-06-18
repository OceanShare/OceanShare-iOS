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
        self.dataSource = self
        self.delegate = self
        // define the first view of the RootViewController
        if let firstViewController = viewControllerList.first {
            self.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
        // apply the design stuff to the view
        configurePageControl()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // check if the user is already logged in
        if UserDefaults.standard.object(forKey: "user_uid_key") != nil {
            if UserDefaults.standard.object(forKey : "user_logged_by_email") != nil {
                
                // check if the user has confirmed its email address
                if (Auth.auth().currentUser?.isEmailVerified == true) {
                    print("-> Email Authentication Success.")
                    
                    // set the userdefaults data
                    UserDefaults.standard.set(Auth.auth().currentUser?.uid, forKey: "user_uid_key")
                    UserDefaults.standard.synchronize()
                    
                    // redirect the user to the map
                    let mainTabBarController = self.storyboard?.instantiateViewController(withIdentifier:   "MainTabBarController") as! MainTabBarController
                    mainTabBarController.selectedViewController = mainTabBarController.viewControllers?[1]
                    self.present(mainTabBarController, animated: true,completion: nil)
                    
                } else {
                    
                    // handle the email confirmation
                    let alert = UIAlertController(title: "Please Confirm Your Email.", message: "You need to confirm your email address to finish your inscription and access to your profile.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Send me an other mail.", style: .default, handler: { action in
                        self.sendEmailVerification()
                        print("~ Action Informations: An Other Mail Has Been Sent.")
                    }))
                    alert.addAction(UIAlertAction(title: "I'll check my emails", style: .default, handler: { action in
                        print("~ Action Information: OK Pressed.")
                    }))
                    self.present(alert, animated: true, completion: nil)
                    
                }
                
            } else {
                // redirect the user to the map
                let mainTabBarController = self.storyboard?.instantiateViewController(withIdentifier:   "MainTabBarController") as! MainTabBarController
                mainTabBarController.selectedViewController = mainTabBarController.viewControllers?[1]
                self.present(mainTabBarController, animated: true,completion: nil)
                
            }
        }
    }
    
    // MARK: - Setup
    
    func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 50,width: UIScreen.main.bounds.width,height: 50))
        self.pageControl.numberOfPages = viewControllerList.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.black
        self.pageControl.pageIndicatorTintColor = UIColor.gray
        self.pageControl.currentPageIndicatorTintColor = UIColor(rgb: 0x57A1FF)
        self.pageControl.layer.position.y = self.view.frame.height - 75
        self.view.addSubview(pageControl)
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
        self.pageControl.currentPage = viewControllerList.firstIndex(of: pageContentViewController)!
    }
    
    // MARK: - Email Verification
    
    func sendEmailVerification(_ callback: ((Error?) -> ())? = nil){
        Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
            callback?(error)
        })
    }
    
}
