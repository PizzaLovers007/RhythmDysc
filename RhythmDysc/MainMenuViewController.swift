//
//  MainMenuViewController.swift
//  RhythmDysc
//
//  Created by MUser on 6/29/15.
//  Copyright (c) 2015 TynyLabs. All rights reserved.
//

import UIKit;

class MainMenuViewController: UIViewController {

    @IBOutlet weak var playGameLabel: UILabel!;
    
    override func viewDidLoad() {
        super.viewDidLoad();

        // Do any additional setup after loading the view.
        let animation = CABasicAnimation(keyPath: "transform.scale");
        animation.toValue = NSNumber(float: 0.9);
        animation.duration = 0.3;
        animation.repeatCount = Float.infinity;
        animation.autoreverses = true;
        playGameLabel.layer.addAnimation(animation, forKey: nil);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
