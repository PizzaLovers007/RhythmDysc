//
//  NavigationControllerDelegate.swift
//  RhythmDysc
//
//  Created by MUser on 6/30/15.
//  Copyright (c) 2015 TynyLabs. All rights reserved.
//

import UIKit;

class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate {
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadeBlackTransitionAnimator();
    }
}
