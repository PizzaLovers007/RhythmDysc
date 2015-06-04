//
//  InGameScene.swift
//  RhythmDysc
//
//  Created by MUser on 6/2/15.
//  Copyright (c) 2015 TynyLabs. All rights reserved.
//

import UIKit;
import SpriteKit;
import AVFoundation;

class InGameScene: SKScene {
    
    let redButton = RedButton();
    let greenButton = GreenButton();
    let blueButton = BlueButton();
    var song: AVAudioPlayer! = nil;
    var redDown: Bool = false;
    var greenDown: Bool = false;
    var blueDown: Bool = false;
    var prevTime: NSTimeInterval = -1;
    var songTime: Double = 0;
    
    init(size: CGSize, songURL: NSURL?) {
        NSLog("\(songURL)");
        song = AVAudioPlayer(contentsOfURL: songURL, error: nil);
        super.init(size: size);
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func didMoveToView(view: SKView) {
        NSLog("Entered the In Game Scene");
        self.backgroundColor = SKColor.whiteColor();
        addButtons();
    }
    
    override func update(currentTime: NSTimeInterval) {
        if (prevTime == -1) {
            prevTime = currentTime;
            return;
        }
        let deltaTime: Double = (currentTime - prevTime) * 1000;
        prevTime = currentTime;
        if (!song.playing) {
            NSLog("Song has finished");
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        for t in touches {
            let touch = t as! UITouch;
            let touchLocation = touch.locationInNode(self);
            let touchedNode = self.nodeAtPoint(touchLocation);
            if (touchedNode.name == "redButton") {
                NSLog("Red button pressed");
                redDown = true;
                redButton.pressButton();
            } else if (touchedNode.name == "greenButton") {
                NSLog("Green button pressed");
                greenDown = true;
                greenButton.pressButton();
            } else if (touchedNode.name == "blueButton") {
                NSLog("Blue button pressed");
                blueDown = true;
                blueButton.pressButton();
            }
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        for t in touches {
            let touch = t as! UITouch;
            let touchLocation = touch.locationInNode(self);
            let prevTouchLocation = touch.previousLocationInNode(self);
            if (redDown && self.nodeAtPoint(touchLocation).name != "redButton" && self.nodeAtPoint(prevTouchLocation).name == "redButton") {
                NSLog("Red button released");
                redDown = false;
                redButton.releaseButton();
            } else if (greenDown && self.nodeAtPoint(touchLocation).name != "greenButton" && self.nodeAtPoint(prevTouchLocation).name == "greenButton") {
                NSLog("Green button released");
                greenDown = false;
                greenButton.releaseButton();
            } else if (blueDown && self.nodeAtPoint(touchLocation).name != "blueButton" && self.nodeAtPoint(prevTouchLocation).name == "blueButton") {
                NSLog("Blue button released");
                blueDown = false;
                blueButton.releaseButton();
            }
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        for t in touches {
            let touch = t as! UITouch;
            let touchLocation = touch.locationInNode(self);
            let touchedNode = self.nodeAtPoint(touchLocation);
            if (touchedNode.name == "redButton" && redDown) {
                NSLog("Red button released");
                redDown = false;
                redButton.releaseButton();
            } else if (touchedNode.name == "greenButton" && greenDown) {
                NSLog("Green button released");
                greenDown = false;
                greenButton.releaseButton();
            } else if (touchedNode.name == "blueButton" && blueDown) {
                NSLog("Blue button released");
                blueDown = false;
                blueButton.releaseButton();
            }
        }
    }
    
    private func addButtons() {
        let buttonWidth = self.size.width/CGFloat(3);
        let halfButtonWidth = buttonWidth/CGFloat(2);
        redButton.size.width = buttonWidth;
        redButton.size.height = buttonWidth;
        redButton.position = CGPoint(x: halfButtonWidth, y: halfButtonWidth);
        greenButton.size.width = buttonWidth;
        greenButton.size.height = buttonWidth;
        greenButton.position = CGPoint(x: halfButtonWidth + buttonWidth, y: halfButtonWidth);
        blueButton.size.width = buttonWidth;
        blueButton.size.height = buttonWidth;
        blueButton.position = CGPoint(x: halfButtonWidth + buttonWidth * CGFloat(2), y: halfButtonWidth);
        addChild(redButton);
        addChild(greenButton);
        addChild(blueButton);
    }
}
