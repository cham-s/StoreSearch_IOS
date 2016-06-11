//
//  SlideOutAnimationController.swift
//  StoreSearch_IOS
//
//  Created by Chamsidine ATTOUMANI on 6/11/16.
//  Copyright © 2016 StellarTech Media. All rights reserved.
//

import  UIKit

class  SlideOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey),
            let containerView = transitionContext.containerView() {
            let duration = transitionDuration(transitionContext)
            
            UIView.animateWithDuration(duration, animations: {
                fromView.center.y -= containerView.bounds.size.height
                }, completion: { finished in
                    transitionContext.completeTransition(finished)
            })
        }
    }
}
