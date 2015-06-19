//
//  SongSelectScene.swift
//  RhythmDysc
//
//  Created by MUser on 6/17/15.
//  Copyright (c) 2015 TynyLabs. All rights reserved.
//

import UIKit;
import SpriteKit;

class SongSelectScene: SKScene {
    
    let selectionHeight: CGFloat;
    let songDetailWindow: SongDetailWindow;
    var currSelection: SongSelection?;
    var selections: [SongSelection] = [SongSelection]();
    var touchedNode: SKNode?;
    var touchDistanceMoved: Double = 0;
    
    override init(size: CGSize) {
        selectionHeight = size.height/7;
        songDetailWindow = SongDetailWindow(size: size);
        super.init(size: size);
    }
    
    required init?(coder aDecoder: NSCoder) {
        selectionHeight = 0;
        songDetailWindow = SongDetailWindow(size: CGSize(width: 0, height: 0));
        super.init(coder: aDecoder);
    }
    
    override func didMoveToView(view: SKView) {
        backgroundColor = UIColor.whiteColor();
        let testSelection = SongSelection(size: CGSize(width: size.width, height: selectionHeight), title: "aLIEz", artist: "SawanoHiroyuki[nZk]:mizuki", maxBPM: 99);
        selections.append(testSelection);
        addChild(testSelection);
        addChild(songDetailWindow);
    }
    
    override func update(currentTime: NSTimeInterval) {
        if (songDetailWindow.hidden && currSelection != nil) {
            userInteractionEnabled = true;
            currSelection = nil;
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch;
        let touchLocation = touch.locationInNode(self);
        if (currSelection == nil) {
            for selectionNode in selections {
                if (selectionNode.containsPoint(touchLocation)) {
                    touchedNode = selectionNode;
                }
            }
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch;
        let touchLocation = touch.locationInNode(self);
        let prevTouchLocation = touch.previousLocationInNode(self);
        if (sqrt(pow(touchLocation.x - prevTouchLocation.x, 2) + pow(touchLocation.y - prevTouchLocation.y, 2)) > 5) {
            NSLog("Setting touchedNode to nil");
            touchedNode = nil;
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch;
        let touchLocation = touch.locationInNode(self);
        if (currSelection == nil) {
            for selectionNode in selections {
                if (selectionNode.containsPoint(touchLocation) && touchedNode != nil) {
                    currSelection = touchedNode as? SongSelection;
                    showSongDetailWindow();
                }
            }
        }
    }
    
    private func showSongDetailWindow() {
        NSLog("Showing Song Details");
        songDetailWindow.setSongSelection(currSelection!);
        songDetailWindow.hidden = false;
        songDetailWindow.userInteractionEnabled = true;
        songDetailWindow.audioPlayer.play();
    }
}
