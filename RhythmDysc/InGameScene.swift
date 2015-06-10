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
    let cursor = Cursor();
    let highlight: SKSpriteNode = SKSpriteNode(imageNamed: "4SectorBlueArc");
    let dysc: SKSpriteNode = SKSpriteNode(imageNamed: "4SectorDysc");
    let mapData: DyscMap;
//    var song: AVAudioPlayer! = nil;
    var redDown: Bool = false;
    var greenDown: Bool = false;
    var blueDown: Bool = false;
    var prevTime: NSTimeInterval = -1;
    var startTime: NSTimeInterval = 0;
    var songTime: Double = 0;
    
    init(size: CGSize, songURL: NSURL, mapData data: DyscMap) {
        NSLog("\(songURL)");
//        song = AVAudioPlayer(contentsOfURL: songURL, error: nil);
//        song.prepareToPlay();
        mapData = data;
        super.init(size: size);
    }

    required init?(coder aDecoder: NSCoder) {
        mapData = DyscMap();
        super.init(coder: aDecoder);
    }
    
    override func didMoveToView(view: SKView) {
        NSLog("Entered the In Game Scene");
        self.backgroundColor = SKColor.whiteColor();
        initializeObjects();
    }
    
    override func update(currentTime: NSTimeInterval) {
        if (prevTime == -1) {
            prevTime = currentTime;
            startTime = currentTime;
            return;
        }
        let currSector: Int = checkCursorPosition();
        let deltaTime: Double = (currentTime - prevTime) * 1000;
        prevTime = currentTime;
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
    
    private func addCursor() {
        cursor.center = dysc.position;
        cursor.radius = Double(dysc.size.width/16*7);
        cursor.position = dysc.position;
        cursor.size = CGSize(width: dysc.size.width/10, height: dysc.size.height/10);
        cursor.alpha = 0;
        cursor.startUpdates();
        addChild(cursor);
    }
    
    private func initializeObjects() {
        let titleChange = max(CGFloat(count(mapData.title)*3), CGFloat(40));
        let artistChange = max(CGFloat(count(mapData.artist)*3), CGFloat(40));
        
        let titleNode = SKLabelNode(text: mapData.title);
        titleNode.alpha = 0;
        titleNode.position = CGPoint(x: size.width/2 + titleChange/2, y: size.height/3*2);
        titleNode.fontColor = SKColor.blackColor();
        titleNode.fontName = "HelveticaNeue-Medium";
        let artistNode = SKLabelNode(text: mapData.artist);
        artistNode.alpha = 0;
        artistNode.position = CGPoint(x: size.width/2 + artistChange/2, y: size.height/3*2-30);
        artistNode.fontColor = SKColor.blackColor();
        artistNode.fontName = "HelveticaNeue-Light";
        
        dysc.size = CGSize(width: self.size.width-40, height: self.size.width-40);
        dysc.position = CGPoint(x: size.width/2, y: size.height/3*2);
        dysc.alpha = 0;
        
        highlight.position = dysc.position;
        highlight.alpha = 0;
        
        let fadeText = SKAction.sequence([SKAction.fadeInWithDuration(0.4), SKAction.waitForDuration(3), SKAction.fadeOutWithDuration(0.4)]);
        let moveTitle = SKAction.moveBy(CGVector(dx: -titleChange, dy: 0), duration: 3.8);
        let moveArtist = SKAction.moveBy(CGVector(dx: -artistChange, dy: 0), duration: 3.8);
        let titleAction = SKAction.group([fadeText, moveTitle]);
        let artistAction = SKAction.group([fadeText, moveArtist]);
        let delaySong = SKAction.waitForDuration(5.0 + Double(mapData.offset)/1000.0)
//        let playSong = SKAction.runBlock({
//            self.song.play();
//        });
        let showField = SKAction.runBlock({
            self.dysc.alpha = 1;
            self.highlight.alpha = 1;
            self.cursor.alpha = 1;
        });
        
        titleNode.runAction(SKAction.sequence([titleAction, showField, delaySong, SKAction.playSoundFileNamed("aLIEz.mp3", waitForCompletion: false)]));
        artistNode.runAction(artistAction);
        
        addButtons();
        addChild(dysc);
        addCursor();
        addChild(highlight);
        addChild(titleNode);
        addChild(artistNode);
    }
    
    private func checkCursorPosition() -> Int {
        let sectorSize = M_PI*2/Double(mapData.sector);
        let theta = cursor.theta;
        let currSector = (Int(round(theta/sectorSize))+4)%4;
        let highlightRotation = CGFloat(round(theta/sectorSize)*sectorSize);
        highlight.runAction(SKAction.rotateToAngle(highlightRotation, duration: 0));
        return currSector;
    }
}
