//
//  ViewController.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 25/12/2018.
//  Copyright © 2018 Joseph Pereniguez. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {
    
    // MARK: definitions
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var pageControll: UIPageControl!
    @IBOutlet weak var startButton: UIButton!
    
    // MARK: loader
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.frame = CGRect(x:0, y:0, width:self.view.frame.width, height:self.view.frame.height)
        
        textView.textAlignment = .center
        
        textView.textColor = UIColor.white
        self.startButton.layer.cornerRadius = 4.0
        
        self.scrollView.contentSize = CGSize(width:self.scrollView.frame.width * 4, height:self.scrollView.frame.height)
        self.scrollView.delegate = self
        self.pageControll.currentPage = 0
    }
    
    // MARK: functions
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth:CGFloat = scrollView.frame.width
        let currentPage:CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1
        
        self.pageControll.currentPage = Int(currentPage);
        
        if Int(currentPage) == 0 {
            textView.text = "Discover OceanShare, your new navigation companion which will change your life on the seas !"
            startButton.isHidden = false
        } else if Int(currentPage) == 1 {
            textView.isHidden = true
            if startButton.isHidden == false {
                startButton.isHidden = true
                
            }
        } else if Int(currentPage) == 2 {
            if startButton.isHidden == false {
                startButton.isHidden = true
                
            }
            
        } else {
            if startButton.isHidden == false {
                startButton.isHidden = true
                
            }
            self.startButton.alpha = 1.0
        }
    }
    
    @objc func moveToNextPage () {
        
        let pageWidth:CGFloat = self.scrollView.frame.width
        let maxWidth:CGFloat = pageWidth * 4
        let contentOffset:CGFloat = self.scrollView.contentOffset.x
        
        var slideToX = contentOffset + pageWidth
        
        if  contentOffset + pageWidth == maxWidth {
            slideToX = 0
            
        }
        self.scrollView.scrollRectToVisible(CGRect(x:slideToX, y:0, width:pageWidth, height:self.scrollView.frame.height), animated: true)
    }
    
    // MARK: Actions
    
    @IBAction func startHandler(_ sender: UIButton) {
        moveToNextPage()
        startButton.isHidden = true
    }
    
}
