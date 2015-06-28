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
    var startTouchLocation: CGPoint?;
    var isMovingByTouch: Bool = false;
    var selectionVelocity: CGFloat = 0;
    
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
        backgroundColor = UIColor.blackColor();
        for (var i = 0; i < 20; i++) {
            let testSelection = SongSelection(size: CGSize(width: size.width, height: selectionHeight), title: "aLIEz", artist: "SawanoHiroyuki[nZk]:mizuki", maxBPM: 99);
            testSelection.position.y = selectionHeight * CGFloat(i);
            selections.append(testSelection);
            addChild(testSelection);
        }
        addChild(songDetailWindow);
    }
    
    override func update(currentTime: NSTimeInterval) {
        if (songDetailWindow.hidden && currSelection != nil) {
            userInteractionEnabled = true;
            currSelection = nil;
        }
        if (!isMovingByTouch) {
            if (selectionVelocity > 0) {
                selectionVelocity = min(selectionVelocity, selectionHeight-selections.first!.position.y);
            } else {
                selectionVelocity = max(selectionVelocity, size.height-selectionHeight*2-selections.last!.position.y);
            }
            for sel in selections {
                sel.position.y += selectionVelocity;
            }
        }
        selectionVelocity = selectionVelocity * 9 / 10;
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch;
        startTouchLocation = touch.locationInNode(self);
        if (currSelection == nil) {
            for selectionNode in selections {
                if (selectionNode.containsPoint(startTouchLocation!)) {
                    touchedNode = selectionNode;
                }
            }
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch;
        let currTouchLocation = touch.locationInNode(self);
        let prevTouchLocation = touch.previousLocationInNode(self);
        if (startTouchLocation != nil) {
            let dist = hypot(startTouchLocation!.x - currTouchLocation.x, startTouchLocation!.y - currTouchLocation.y);
            if (dist > 10 || isMovingByTouch) {
                isMovingByTouch = true;
                NSLog("Setting touchedNode to nil");
                touchedNode = nil;
                
                let touchYChange = currTouchLocation.y - touch.previousLocationInNode(self).y;
                let yChange: CGFloat;
                if (touchYChange > 0) {
                    yChange = min(touchYChange, selectionHeight-selections.first!.position.y);
                } else {
                    yChange = max(touchYChange, size.height-selectionHeight*2-selections.last!.position.y);
                }
                selectionVelocity = yChange;
                for sel in selections {
                    sel.position.y += yChange;
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch;
        let currTouchLocation = touch.locationInNode(self);
        let prevTouchLocation = touch.previousLocationInNode(self);
        if (currSelection == nil) {
            for selectionNode in selections {
                if (selectionNode.containsPoint(currTouchLocation) && touchedNode != nil) {
                    currSelection = touchedNode as? SongSelection;
                    showSongDetailWindow();
                }
            }
        }
        startTouchLocation = nil;
        isMovingByTouch = false;
    }
    
    private func showSongDetailWindow() {
        NSLog("Showing Song Details");
        songDetailWindow.setSongSelection(currSelection!);
        songDetailWindow.hidden = false;
        songDetailWindow.userInteractionEnabled = true;
        songDetailWindow.audioPlayer.play();
    }
}
