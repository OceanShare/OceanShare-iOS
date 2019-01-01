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
    
    // MARK: definitions
    
    lazy var viewControllerList:[UIViewController] = {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        
        let vc1 = sb.instantiateViewController(withIdentifier: "StartViewController")
        let vc2 = sb.instantiateViewController(withIdentifier: "LoginViewController")
        let vc3 = sb.instantiateViewController(withIdentifier: "SignupViewController")
        
        return [vc1, vc2, vc3]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self
        
        if let firstViewController = viewControllerList.first {
            self.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    // MARK: functions
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let vcIndex = viewControllerList.index(of: viewController) else { return nil }
        let previousIndex = vcIndex - 1
        
        guard previousIndex >= 0 else { return nil }
        guard viewControllerList.count > previousIndex else { return nil }
        
        return viewControllerList[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let vcIndex = viewControllerList.index(of: viewController) else { return nil }
        let nextIndex = vcIndex + 1
        
        guard viewControllerList.count != nextIndex else { return nil }
        guard viewControllerList.count > nextIndex else { return nil }
        
        return viewControllerList[nextIndex]
    }
    
    public func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return viewControllerList.count
    }
    
    /*public func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = viewControllerList.index(of: firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }*/
    
    
}
