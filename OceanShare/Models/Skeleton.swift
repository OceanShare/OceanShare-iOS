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
    
    /**
     - Description - Turn on an animation on an image view and set an optionnal corner radius.
     - Inputs - image `UIImageView` & cornerRadius `Double`
     */
    func turnOnSkeleton(image: UIImageView, cornerRadius: Double) {
        image.layer.cornerRadius = CGFloat(cornerRadius)
        image.clipsToBounds = true
        image.isSkeletonable = true
        image.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
        
    }
    
    /**
     - Description - Turn on an animation on a view and set an optionnal corner radius. This view can be used as a laber loading animation.
     - Inputs - view `DesignableView` & cornerRadius `Double`
     */
    func turnOnSkeletonContainer(view: DesignableView, cornerRadius: Double) {
        view.isHidden = false
        view.cornerRadius = CGFloat(cornerRadius)
        view.clipsToBounds = true
        view.isSkeletonable = true
        view.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
    }
    
    /**
     - Description - Turn off the image loading animation.
     - Inputs - image `UIImageView`
     */
    func turnOffSkeleton(image: UIImageView) {
        image.hideSkeleton()
        
    }
    
    /**
     - Description - Turn off the view loading animation.
     - Inputs - view `DesignableView`
     */
    func turnOffSkeletonContainer(view: DesignableView) {
        view.hideSkeleton()
        view.isHidden = true
    }
}
