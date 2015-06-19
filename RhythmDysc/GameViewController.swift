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

        let documentDirectoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as! NSURL;
        
        let songURL = NSBundle.mainBundle().URLForResource("aLIEz", withExtension: "mp3");
        let mapURL = NSBundle.mainBundle().URLForResource("aLIEz-expert-4", withExtension: "dmp");
        if (songURL == nil || mapURL == nil) {
            return;
        }
        let mapData: DyscMap = MapReader.readFile(mapURL!);
//        let scene = InGameScene(size: view.bounds.size, songURL: songURL!, mapData: mapData);
        let scene = TitleScreenScene(size: view.bounds.size);
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
