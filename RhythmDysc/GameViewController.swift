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
    
    var mapData: DyscMap!;
    
    override func viewDidLoad() {
        super.viewDidLoad();

        let documentDirectoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as! NSURL;
        
        // Configure the view.
        let skView = self.view as! SKView;
        skView.showsFPS = true;
        skView.showsNodeCount = true;
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true;
        
        skView.backgroundColor = UIColor.blackColor();
        
        if (mapData != nil) {
            let songURL = NSBundle.mainBundle().URLForResource(mapData.title, withExtension: "mp3");
            if (songURL == nil) {
                return;
            }
            let scene = InGameScene(size: view.bounds.size, songURL: songURL!, mapData: mapData);
//            let scene = ResultsScene(size: view.bounds.size, mapData: mapData);
            
            scene.viewController = self;
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .ResizeFill;
            
            skView.presentScene(scene);
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if (mapData == nil) {
            performSegueWithIdentifier("backToSongSelect", sender: self);
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        if let scene = (view as! SKView).scene, let gameScene = scene as? InGameScene {
            gameScene.songPlayer.pause()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        (view as! SKView).presentScene(nil);
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
