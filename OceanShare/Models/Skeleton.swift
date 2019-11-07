//
//  Skeleton.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 01/11/2019.
//  Copyright © 2019 Joseph Pereniguez. All rights reserved.
//

import UIKit
import Foundation
import SkeletonView

struct Skeleton {
    let gradient = SkeletonGradient(baseColor: UIColor.clouds)
    let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .topLeftBottomRight)
    
    // MARK: - Functions
    
    /*
     * Turn on an animation on the image view given as parameter
     * and set an optionnal corner radius.
     */
    func turnOnSkeleton(image: UIImageView, cornerRadius: Double) {
        image.layer.cornerRadius = CGFloat(cornerRadius)
        image.clipsToBounds = true
        image.isSkeletonable = true
        image.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
        
    }
    
    /*
     * Turn on an animation on a view given as parameter
     * and set an optionnal corner radius. This view can be used
     * as a laber loading animation.
     */
    func turnOnSkeletonContainer(view: DesignableView, cornerRadius: Double) {
        view.isHidden = false
        view.cornerRadius = CGFloat(cornerRadius)
        view.clipsToBounds = true
        view.isSkeletonable = true
        view.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
    }
    
    /*
     * Turn off the image loading animation.
     */
    func turnOffSkeleton(image: UIImageView) {
        image.hideSkeleton()
        
    }
    
    /*
     * Turn off the view loading animation.
     */
    func turnOffSkeletonContainer(view: DesignableView) {
        view.hideSkeleton()
        view.isHidden = true
    }
}
