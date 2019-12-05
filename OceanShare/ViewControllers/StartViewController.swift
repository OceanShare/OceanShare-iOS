//
//  StartViewController.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 25/12/2018.
//  Copyright © 2018 Joseph Pereniguez. All rights reserved.
//

import UIKit
import Foundation
import Crashlytics
import Fabric

class StartViewController: UIViewController, UIPageViewControllerDelegate, UIScrollViewDelegate {
    
    // MARK: - Variables
    
    let registry = Registry()
    var slides:[Slide] = [];
    
    // MARK: - Outlets
    
    /* view */
    @IBOutlet weak var oceanshareLogo: UIImageView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var crashButton: UIButton!
    @IBOutlet var walkthroughView: UIView!
    
    /* walkthrough view */
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var walkthroughSquare: DesignableView!
    @IBOutlet weak var firstSlideButton: DesignableButton!
    @IBOutlet weak var secondSlideButton: DesignableButton!
    @IBOutlet weak var thirdSlideButton: DesignableButton!
    @IBOutlet weak var skipWalkthroughLabel: DesignableButton!
    
    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        setupView()

    }
    
    // MARK: - Setup
    
    func setupView() {
        /* set the gradiant */
        let color1 = registry.customClearBlue
        let color2 = registry.customWhiteBlue
        startButton.applyGradient(colours:[color1, color2], corner:27.5)
        /* set the crash button */
        crashButton.isHidden = true
        // Fabric.sharedSDK().debug = true
        /* set the walkthrough page control */
        scrollView.layer.cornerRadius = 15
        scrollView.layer.masksToBounds = true
        scrollView.delegate = self
        slides = createSlides()
        setupSlideScrollView(slides: slides)
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        view.bringSubviewToFront(pageControl)
        /* set localized labels */
        setupLocalizedStrings()
        
    }
    
    func setupLocalizedStrings() {
        startButton.setTitle(NSLocalizedString("startButton", comment: ""), for: .normal)
        skipWalkthroughLabel.setTitle(NSLocalizedString("skipWalkthrough", comment: ""), for: .normal)
    }
    
    // MARK: - Actions
    
    /*
     * This action needs the shared SDK to be activated on its debug mode
     */
    @IBAction func didPressCrash(_ sender: Any) {
        print("Crash Button Pressed!")
        Crashlytics.sharedInstance().crash()
        
    }
    
    @IBAction func showWalkthrough(_ sender: Any) {
        view.addSubview(walkthroughView)
        walkthroughView.center = view.center
        
        walkthroughView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        walkthroughView.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            self.walkthroughView.alpha = 1
            self.walkthroughView.transform = CGAffineTransform.identity
            self.startButton.isHidden = true
            self.oceanshareLogo.isHidden = true
            
        }
    }
    
    @IBAction func closeWalkthrough(_ sender: Any) {
        startButton.isHidden = false
        oceanshareLogo.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
                self.walkthroughView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                self.walkthroughView.alpha = 0
                
            }
        ) { (success:Bool) in
            self.walkthroughView.removeFromSuperview()
            /* if the user already know the app = redirection to the login view */
            let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            self.present(loginViewController, animated: true,completion: nil)
            
        }
    }
    
    /*
     * Scroll the size of the whole scroll view malus 2/3 of itself
     */
    @IBAction func firstPressed(_ sender: Any) {
        let rightOffset = scrollView!.contentSize.width - scrollView!.bounds.size.width * 2
        self.scrollView!.setContentOffset(CGPoint(x: rightOffset, y: 0), animated: true)
        
    }
    
    /*
     * Scroll the size of the whole scroll view malus 1/3 of itself
     */
    @IBAction func secondPressed(_ sender: Any) {
        let rightOffset = scrollView!.contentSize.width - scrollView!.bounds.size.width
        self.scrollView!.setContentOffset(CGPoint(x: rightOffset, y: 0), animated: true)
        
    }
    
    // MARK: - Functions
    
    func createSlides() -> [Slide] {
        let slide1:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide1.imageView.image = registry.slide1
        
        let slide2:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide2.imageView.image = registry.slide2
        
        let slide3:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide3.imageView.image = registry.slide3
        
        return [slide1, slide2, slide3]
        
    }
    
    func setupSlideScrollView(slides : [Slide]) {
        scrollView.frame = CGRect(x: 0, y: 0, width: walkthroughSquare.frame.width, height: walkthroughSquare.frame.height)
        scrollView.contentSize = CGSize(width: walkthroughSquare.frame.width * CGFloat(slides.count), height: walkthroughSquare.frame.height)
        scrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: walkthroughSquare.frame.width * CGFloat(i), y: 0, width: walkthroughSquare.frame.width, height: walkthroughSquare.frame.height)
            scrollView.addSubview(slides[i])
            
        }
    }
    
    /*
     * default function called when view is scolled. In order to enable callback
     * when scrollview is scrolled, the below code needs to be called:
     * slideScrollView.delegate = self or
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
        
        if (Int(pageIndex) == 0) {
            self.firstSlideButton.isHidden = false
            self.secondSlideButton.isHidden = true
            self.thirdSlideButton.isHidden = true
        } else if (Int(pageIndex) == 1) {
            self.firstSlideButton.isHidden = true
            self.secondSlideButton.isHidden = false
            self.thirdSlideButton.isHidden = true
        } else if (Int(pageIndex) == 2) {
            self.firstSlideButton.isHidden = true
            self.secondSlideButton.isHidden = true
            self.thirdSlideButton.isHidden = false
        }

    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupSlideScrollView(slides: slides)
        
    }
    
}
