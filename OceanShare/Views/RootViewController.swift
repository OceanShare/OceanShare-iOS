//
//  RootViewController.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 26/12/2018.
//  Copyright © 2018 Joseph Pereniguez. All rights reserved.
//

import UIKit

class RootViewController: UIPageViewController, UIPageViewControllerDataSource {
    
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
    
    
}
