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
    
    var pageControl = UIPageControl()
    
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
        
        configurePageControl()
    }
    
    /*
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let pageVC = UIPageControl()
        
        for view in self.view.subviews {
            if view is UIScrollView {
                let pageControl = UIPageControl()
                pageControl.pageIndicatorTintColor = UIColor.gray
                pageControl.currentPageIndicatorTintColor = UIColor.blue
                pageControl.backgroundColor = UIColor.darkGray
                pageControl.numberOfPages = viewControllerList.count
                pageControl.center = self.view.center
                self.view.addSubview(pageControl)
                pageControl.layer.position.y = self.view.frame.height - 100;
            } else if view is UIPageControl {
                view.backgroundColor = UIColor.clear
                pageVC.numberOfPages = 3
                pageVC.center = self.view.center
                pageVC.layer.position.y = self.view.frame.height - 180 ;
                
            }
        }
    }*/
    
    // MARK: data source functions
    
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
    
    // MARK: Delegate methods
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = viewControllerList.index(of: pageContentViewController)!
    }
    
    // MARK: setup functions
    
    func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 50,width: UIScreen.main.bounds.width,height: 50))
        
        self.pageControl.numberOfPages = viewControllerList.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.black
        self.pageControl.pageIndicatorTintColor = UIColor.gray
        self.pageControl.currentPageIndicatorTintColor = UIColor(rgb: 0x57A1FF)
        self.pageControl.layer.position.y = self.view.frame.height - 75 ;

        self.view.addSubview(pageControl)
    }
    
}
