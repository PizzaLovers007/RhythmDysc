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
    var songHasStarted: Bool = false;
    
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
            startTime = currentTime + 6.8 - Double(mapData.offset)/1000.0;
            return;
        }
        if (songHasStarted) {
            songHasStarted = false;
            startTime = currentTime;
        }
        let currSector: Int = checkCursorPosition();
        mapData.currSector = currSector;
        mapData.update(songTime: currentTime - startTime, cursorTheta: cursor.theta);
        mapData.updateNotePositions(songTime: currentTime - startTime, dysc: dysc);
        let deltaTime: Double = (currentTime - prevTime) * 1000;
        prevTime = currentTime;
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        for t in touches {
            let touch = t as! UITouch;
            let touchLocation = touch.locationInNode(self);
            let touchedNode = self.nodeAtPoint(touchLocation);
            if (!redDown && touchedNode.name == "redButton") {
                NSLog("Red button pressed");
                redDown = true;
                redButton.pressButton();
                mapData.updateButton(ButtonColor.RED, isPressed: true);
            } else if (!greenDown && touchedNode.name == "greenButton") {
                NSLog("Green button pressed");
                greenDown = true;
                greenButton.pressButton();
                mapData.updateButton(ButtonColor.GREEN, isPressed: true);
            } else if (!blueDown && touchedNode.name == "blueButton") {
                NSLog("Blue button pressed");
                blueDown = true;
                blueButton.pressButton();
                mapData.updateButton(ButtonColor.BLUE, isPressed: true);
                
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
                mapData.updateButton(ButtonColor.RED, isPressed: false);
            } else if (greenDown && self.nodeAtPoint(touchLocation).name != "greenButton" && self.nodeAtPoint(prevTouchLocation).name == "greenButton") {
                NSLog("Green button released");
                greenDown = false;
                greenButton.releaseButton();
                mapData.updateButton(ButtonColor.GREEN, isPressed: false);
            } else if (blueDown && self.nodeAtPoint(touchLocation).name != "blueButton" && self.nodeAtPoint(prevTouchLocation).name == "blueButton") {
                NSLog("Blue button released");
                blueDown = false;
                blueButton.releaseButton();
                mapData.updateButton(ButtonColor.BLUE, isPressed: false);
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
                mapData.updateButton(ButtonColor.RED, isPressed: false);
            } else if (touchedNode.name == "greenButton" && greenDown) {
                NSLog("Green button released");
                greenDown = false;
                greenButton.releaseButton();
                mapData.updateButton(ButtonColor.GREEN, isPressed: false);
            } else if (touchedNode.name == "blueButton" && blueDown) {
                NSLog("Blue button released");
                blueDown = false;
                blueButton.releaseButton();
                mapData.updateButton(ButtonColor.BLUE, isPressed: false);
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
        let delaySong = SKAction.waitForDuration(max(3.0 - Double(mapData.offset)/1000.0, 0));
        let startSongTimer = SKAction.runBlock({
            self.songHasStarted = true;
        });
//        let playSong = SKAction.runBlock({
//            self.song.play();
//        });
        let showField = SKAction.runBlock({
            self.dysc.alpha = 1;
            self.highlight.alpha = 1;
            self.cursor.alpha = 1;
        });
        
        titleNode.runAction(SKAction.sequence([titleAction, showField, delaySong, startSongTimer, SKAction.playSoundFileNamed("aLIEz.mp3", waitForCompletion: false)]));
        artistNode.runAction(artistAction);
        
        mapData.comboTitle.position = CGPoint(x: size.width/2, y: size.height/4);
        mapData.comboTitle.zPosition = 100;
        mapData.comboTitle.fontColor = UIColor.blackColor();
        mapData.judgmentTitle.position = CGPoint(x: size.width/2, y: size.height/3);
        mapData.judgmentTitle.zPosition = 100;
        mapData.judgmentTitle.fontColor = UIColor.blackColor();
        
        addButtons();
        addChild(dysc);
        addCursor();
        addChild(highlight);
        addChild(titleNode);
        addChild(artistNode);
        for note in mapData.notes {
            addChild(note);
            NSLog("\(note.texture?.description)");
            note.position = dysc.position;
            note.size = CGSize(width: dysc.size.width/2*(1-1/sqrt(2)), height: dysc.size.height/sqrt(2));
        }
        addChild(mapData.soundPlayer);
        addChild(mapData.comboTitle);
        addChild(mapData.judgmentTitle);
        
        
        //TEMPORARY HOLD NOTE CODE
        let holdPath = CGPathCreateMutable();
        let holdPath2 = CGPathCreateMutable();
        let rInner = 30.0;
        let rOuter = 200.0;
        let thetaStart = -3*M_PI_4;
        let thetaEnd = -M_PI_4;
        let dTheta = thetaEnd - thetaStart;
        let numSteps = 30.0;
        let step = (thetaEnd - thetaStart)/numSteps;
        CGPathMoveToPoint(holdPath, nil, CGFloat(-rOuter/sqrt(2)+200), CGFloat(-rOuter/sqrt(2)+300));
        CGPathMoveToPoint(holdPath2, nil, CGFloat(-rOuter/sqrt(2)+200), CGFloat(-rOuter/sqrt(2)+300));
        CGPathAddCurveToPoint(holdPath2, nil, 200, 125, 200, 300, 200+30/sqrt(2), 300-30/sqrt(2));
        var i: Double;
        for i = 0; i <= numSteps; i++ {
            let t = thetaStart + step*i;
            let x = CGFloat((rOuter - 2*(rOuter-rInner)*(t-thetaStart)/M_PI) * cos(t))+200;
            let y = CGFloat((rOuter - 2*(rOuter-rInner)*(t-thetaStart)/M_PI) * sin(t))+300;
            NSLog("(\(x), \(y))");
            CGPathAddLineToPoint(holdPath, nil, x, y);
        }
        CGPathAddArc(holdPath, nil, 0+200, 0+300, CGFloat(rInner), CGFloat(thetaStart+dTheta), CGFloat(thetaEnd+dTheta), false);
        CGPathAddArc(holdPath2, nil, 0+200, 0+300, CGFloat(rInner), CGFloat(thetaStart+dTheta), CGFloat(thetaEnd+dTheta), false);
        CGPathAddCurveToPoint(holdPath2, nil, 200, 300, 375, 300, 200+200/sqrt(2), 300-200/sqrt(2));
        for i = numSteps; i >= 0; i-- {
            let t = thetaEnd + step*i;
            let x = CGFloat((rOuter - 2*(rOuter-rInner)*(t-thetaEnd)/M_PI) * cos(t))+200;
            let y = CGFloat((rOuter - 2*(rOuter-rInner)*(t-thetaEnd)/M_PI) * sin(t))+300;
            NSLog("(\(x), \(y))");
            CGPathAddLineToPoint(holdPath, nil, x, y);
        }
        CGPathAddArc(holdPath, nil, 0+200, 0+300, CGFloat(rOuter), CGFloat(thetaEnd), CGFloat(thetaStart), true);
        CGPathAddArc(holdPath2, nil, 0+200, 0+300, CGFloat(rOuter), CGFloat(thetaEnd), CGFloat(thetaStart), true);
        CGPathCloseSubpath(holdPath);
        CGPathCloseSubpath(holdPath2);
        let holdTest = SKShapeNode(path: holdPath);
        let holdTest2 = SKShapeNode(path: holdPath2);
        holdTest.strokeColor = UIColor.brownColor();
        holdTest.zPosition = 10;
        holdTest2.strokeColor = UIColor.blackColor();
        holdTest2.zPosition = 10;
        let holdTestAction = SKAction.repeatActionForever(SKAction.sequence([SKAction.moveBy(CGVector(dx: -50, dy: 0), duration: 3), SKAction.moveBy(CGVector(dx: 50, dy: 0), duration: 3)]));
        holdTest.runAction(holdTestAction);
//        addChild(holdTest);
//        addChild(holdTest2);
        //END TEMPORARY HOLD NOTE CODE
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
