//
//  FadeBlackTransitionAnimator.swift
//  RhythmDysc
//
//  Created by MUser on 6/30/15.
//  Copyright (c) 2015 TynyLabs. All rights reserved.
//

import UIKit

class FadeBlackTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.8;
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView();
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!;
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!;
        
        toViewController.view.alpha = 0;
        containerView.addSubview(toViewController.view);
        
        UIView.animateWithDuration(0.4, animations: {
            fromViewController.view.alpha = 0;
        });
        UIView.animateWithDuration(0.4, delay: 0.4, options: nil, animations: {
                toViewController.view.alpha = 1;
            }, completion: { finished in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled());
        });
    }
}
