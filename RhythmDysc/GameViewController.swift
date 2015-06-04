//
//  GameViewController.swift
//  RhythmDysc
//
//  Created by MUser on 6/1/15.
//  Copyright (c) 2015 TynyLabs. All rights reserved.
//

import UIKit;
import SpriteKit;

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad();

        let songPath = NSBundle.mainBundle().pathForResource("aLIEz", ofType: "mp3");
        if (songPath == nil) {
            return;
        }
        let songURL = NSURL(fileURLWithPath: songPath!);
        let scene = InGameScene(size: view.bounds.size, songURL: songURL);
        // Configure the view.
        let skView = self.view as! SKView;
        skView.showsFPS = true;
        skView.showsNodeCount = true;
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true;
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .ResizeFill;
        
        skView.presentScene(scene);
    }

    override func shouldAutorotate() -> Bool {
        return true;
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue);
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue);
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
}
