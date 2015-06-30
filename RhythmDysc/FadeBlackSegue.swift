//
//  FadeBlackSegue.swift
//  RhythmDysc
//
//  Created by MUser on 6/29/15.
//  Copyright (c) 2015 TynyLabs. All rights reserved.
//

import UIKit;

class FadeBlackSegue: UIStoryboardSegue {
    
    override func perform() {
        let sourceViewController = self.sourceViewController as! UIViewController;
        let destViewController = self.destinationViewController as! UIViewController;
        let window = UIApplication.sharedApplication().keyWindow!;
        
        window.insertSubview(destViewController.view, belowSubview: sourceViewController.view);
        destViewController.view.alpha = 0;
        UIView.animateWithDuration(0.4, animations: {
            sourceViewController.view.alpha = 0;
        });
        UIView.animateWithDuration(0.4, delay: 0.4, options: nil, animations: {
            destViewController.view.alpha = 1;
        }, completion: {(finished) -> Void in
            sourceViewController.presentViewController(destViewController, animated: false, completion: nil);
        });
    }
}
