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
    
    /* List the view controller from the root view controller. */
    lazy var viewControllerList:[UIViewController] = {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc1 = sb.instantiateViewController(withIdentifier: "StartViewController")
        let vc2 = sb.instantiateViewController(withIdentifier: "LoginViewController")
        let vc3 = sb.instantiateViewController(withIdentifier: "SignupViewController")
        return [vc1, vc2, vc3]
        
    }()
    
    // MARK: - View Manager
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /* Define the Firebase variable. */
        dataSource = self
        delegate = self
        /* Define the first view of the RootViewController. */
        if let firstViewController = viewControllerList.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
            
        }
        configurePageControl()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /* The line below is used for connection tests. */
        //Defaults.clearUserData()
        if (Defaults.getUserDetails().uid.isEmpty == false) {
            if Defaults.getUserDetails().isEmail == true {
                Auth.auth().currentUser!.reload(completion: { (error) in
                    if (Auth.auth().currentUser?.isEmailVerified == true) {
                        self.redirectToHome()
                        
                    } else {
                        self.emailConfirmationAlert()
                        
                    }
                })
            } else {
                /* User logged by social networks. */
                redirectToHome()
                
            }
        }
    }
    
    // MARK: - Setup
    
    /**
     - Description - Setup the page control (number of slides, design of the slides...). The total number of pages that are available is based on how many available colors we have.
     */
    func configurePageControl() {
        pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 50,width: UIScreen.main.bounds.width,height: 50))
        pageControl.numberOfPages = viewControllerList.count
        pageControl.currentPage = 0
        pageControl.tintColor = registry.customBlack
        pageControl.pageIndicatorTintColor = registry.customDarkGrey
        pageControl.currentPageIndicatorTintColor = registry.customClearBlue
        pageControl.layer.position.y = view.frame.height - 75
        view.addSubview(pageControl)
    }
    
    // MARK: - Functions
    
    /**
     - Description - Display an alert if the user has to verify its email.
     */
    func emailConfirmationAlert() {
        let alert = UIAlertController(title: NSLocalizedString("alertRootTitle", comment: ""), message: NSLocalizedString("alertRootDesc", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("alertRootActionOne", comment: ""), style: .default, handler: { action in
            User.sendEmailVerification()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("alertRootActionTwo", comment: ""), style: .default, handler: { action in
            let loginViewController = self.storyboard?.instantiateViewController(withIdentifier:   "LoginViewController") as! LoginViewController
            self.present(loginViewController, animated: true,completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    /**
     - Description - Present the `HomeViewController` if the user is already logged.
     */
    func redirectToHome() {
        let mainTabBarController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
        mainTabBarController.selectedViewController = mainTabBarController.viewControllers?[0]
        self.present(mainTabBarController, animated: true,completion: nil)
        
    }
    
    // MARK: - Datasource Functions
    
    /**
     - Description - Handle the left swipe on the `UIPageViewController`.
     - Inputs - pageViewController `UIPageViewController` & viewController `UIViewController`
     - Output - `UIViewController` left view controller
     */
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = viewControllerList.firstIndex(of: viewController) else { return nil }
        let previousIndex = vcIndex - 1
        guard previousIndex >= 0 else { return nil }
        guard viewControllerList.count > previousIndex else { return nil }
        return viewControllerList[previousIndex]
    }
    
    /**
    - Description - Handle the right swipe on the `UIPageViewController`.
    - Inputs - pageViewController `UIPageViewController` & viewController `UIViewController`
    - Output - `UIViewController` right view controller
    */
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = viewControllerList.firstIndex(of: viewController) else { return nil }
        let nextIndex = vcIndex + 1
        guard viewControllerList.count != nextIndex else { return nil }
        guard viewControllerList.count > nextIndex else { return nil }
        return viewControllerList[nextIndex]
    }
    
    // MARK: - Delegate Methods

    /**
     - Description - Handle the indexing of the current `UIViewController`.
     - Inputs - pageViewController `UIPageViewController` & finished `Bool` & previousViewControllers `[UIViewController]` & completed `Bool`
     */
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        pageControl.currentPage = viewControllerList.firstIndex(of: pageContentViewController)!
    }
    
}
