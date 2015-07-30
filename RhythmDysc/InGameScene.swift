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
    let highlight = SKSpriteNode(imageNamed: "4SectorBlueArc");
    let dysc = SKSpriteNode(imageNamed: "4SectorDysc");
    let centerSprite = SKSpriteNode(imageNamed: "Cursor");
    let mapData: DyscMap;
    var songPlayer: AVAudioPlayer! = nil;
    var redDown: Bool = false;
    var greenDown: Bool = false;
    var blueDown: Bool = false;
    var prevTime: NSTimeInterval = -1;
    var startTime: NSTimeInterval = 0;
    var viewController: GameViewController!;
    
    init(size: CGSize, songURL: NSURL, mapData data: DyscMap) {
        songPlayer = AVAudioPlayer(contentsOfURL: songURL, error: nil);
        mapData = data;
        super.init(size: size);
        mapData.scene = self;
    }

    required init?(coder aDecoder: NSCoder) {
        mapData = DyscMap();
        super.init(coder: aDecoder);
    }
    
    override func didMoveToView(view: SKView) {
        NSLog("Entered the In Game Scene");
        self.backgroundColor = SKColor.whiteColor();
        initializeObjects();
        songPlayer.delegate = self;
    }
    
    override func update(currentTime: NSTimeInterval) {
        if (prevTime == -1) {
            prevTime = currentTime;
            return;
        }
        cursor.updatePosition();
        let currSector: Int = checkCursorPosition();
        mapData.currSector = currSector;
        mapData.update(songTime: songPlayer.currentTime, cursorTheta: cursor.theta);
        mapData.updateNotePositions(songTime: songPlayer.currentTime, dysc: dysc);
        mapData.updateSparks(cursor.theta);
        let deltaTime: Double = (currentTime - prevTime) * 1000;
        prevTime = currentTime;
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        for t in touches {
            let touch = t as! UITouch;
            let touchLocation = touch.locationInNode(self);
            if (!redDown && redButton.containsPoint(touchLocation)) {
                NSLog("Red button pressed");
                redDown = true;
                redButton.pressButton();
                mapData.updateButton(ButtonColor.RED, isPressed: true, songTime: songPlayer.currentTime);
            } else if (!greenDown && greenButton.containsPoint(touchLocation)) {
                NSLog("Green button pressed");
                greenDown = true;
                greenButton.pressButton();
                mapData.updateButton(ButtonColor.GREEN, isPressed: true, songTime: songPlayer.currentTime);
            } else if (!blueDown && blueButton.containsPoint(touchLocation)) {
                NSLog("Blue button pressed");
                blueDown = true;
                blueButton.pressButton();
                mapData.updateButton(ButtonColor.BLUE, isPressed: true, songTime: songPlayer.currentTime);
                
            }
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        for t in touches {
            let touch = t as! UITouch;
            let touchLocation = touch.locationInNode(self);
            let prevTouchLocation = touch.previousLocationInNode(self);
            if (redDown && !redButton.containsPoint(touchLocation) && redButton.containsPoint(prevTouchLocation)) {
                NSLog("Red button released");
                redDown = false;
                redButton.releaseButton();
                mapData.updateButton(ButtonColor.RED, isPressed: false, songTime: songPlayer.currentTime);
            } else if (greenDown && !greenButton.containsPoint(touchLocation) && greenButton.containsPoint(prevTouchLocation)) {
                NSLog("Green button released");
                greenDown = false;
                greenButton.releaseButton();
                mapData.updateButton(ButtonColor.GREEN, isPressed: false, songTime: songPlayer.currentTime);
            } else if (blueDown && !blueButton.containsPoint(touchLocation) && blueButton.containsPoint(prevTouchLocation)) {
                NSLog("Blue button released");
                blueDown = false;
                blueButton.releaseButton();
                mapData.updateButton(ButtonColor.BLUE, isPressed: false, songTime: songPlayer.currentTime);
            }
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        for t in touches {
            let touch = t as! UITouch;
            let touchLocation = touch.locationInNode(self);
            if (redButton.containsPoint(touchLocation) && redDown) {
                NSLog("Red button released");
                redDown = false;
                redButton.releaseButton();
                mapData.updateButton(ButtonColor.RED, isPressed: false, songTime: songPlayer.currentTime);
            } else if (greenButton.containsPoint(touchLocation) && greenDown) {
                NSLog("Green button released");
                greenDown = false;
                greenButton.releaseButton();
                mapData.updateButton(ButtonColor.GREEN, isPressed: false, songTime: songPlayer.currentTime);
            } else if (blueButton.containsPoint(touchLocation) && blueDown) {
                NSLog("Blue button released");
                blueDown = false;
                blueButton.releaseButton();
                mapData.updateButton(ButtonColor.BLUE, isPressed: false, songTime: songPlayer.currentTime);
            }
        }
    }
    
    private func addButtons() {
        let buttonWidth = (size.width-20)/3;
        let halfButtonWidth = buttonWidth/2;
        blueButton.size.width = buttonWidth;
        blueButton.size.height = buttonWidth;
        blueButton.position = CGPoint(x: halfButtonWidth+5, y: halfButtonWidth+5);
        greenButton.size.width = buttonWidth;
        greenButton.size.height = buttonWidth;
        greenButton.position = CGPoint(x: size.width/2, y: halfButtonWidth+5);
        redButton.size.width = buttonWidth;
        redButton.size.height = buttonWidth;
        redButton.position = CGPoint(x: size.width-halfButtonWidth-5, y: halfButtonWidth+5);
        addChild(redButton);
        addChild(greenButton);
        addChild(blueButton);
    }
    
    private func addCursor() {
        cursor.center = dysc.position;
        cursor.radius = Double(dysc.size.width/512*249);
        cursor.position = dysc.position;
        cursor.size = CGSize(width: dysc.size.width/10, height: dysc.size.height/10);
        cursor.alpha = 0;
        cursor.zPosition = 10;
        cursor.startUpdates();
        addChild(cursor);
    }
    
    private func initializeObjects() {
        let titleChange = max(CGFloat(count(mapData.title)*3), 40);
        let artistChange = max(CGFloat(count(mapData.artist)*3), 40);
        
        let titleNode = SKLabelNode(text: mapData.title);
        let titlePositionX = size.width/2 + titleChange/2;
        let titlePositionY = size.height/3*2;
        titleNode.alpha = 0;
        titleNode.position = CGPoint(x: titlePositionX, y: titlePositionY);
        titleNode.fontColor = SKColor.blackColor();
        titleNode.fontName = "HelveticaNeue-Medium";
        let artistNode = SKLabelNode(text: mapData.artist);
        let artistPositionX = size.width/2 + artistChange/2;
        let artistPositionY = titlePositionY-30;
        artistNode.alpha = 0;
        artistNode.position = CGPoint(x: artistPositionX, y: artistPositionY);
        artistNode.fontColor = SKColor.blackColor();
        artistNode.fontSize = artistNode.fontSize*2/3;
        artistNode.fontName = "HelveticaNeue-Light";
        let calculatingTiltNode = SKLabelNode(text: "Hold device flat. Tilt a lot when playing!");
        calculatingTiltNode.alpha = 0;
        calculatingTiltNode.position = CGPoint(x: size.width/2, y: size.height/4);
        calculatingTiltNode.fontColor = SKColor.blackColor();
        calculatingTiltNode.fontSize = calculatingTiltNode.fontSize/2;
        calculatingTiltNode.fontName = "HelveticaNeue-Medium";
        
        dysc.size = CGSize(width: self.size.width-40, height: self.size.width-40);
        dysc.position = CGPoint(x: size.width/2, y: size.height/3*2);
        dysc.alpha = 0;
        dysc.zPosition = -10;
        
        highlight.position = dysc.position;
        highlight.alpha = 0;
        
        let fadeText = SKAction.sequence([SKAction.fadeInWithDuration(0.4), SKAction.waitForDuration(3), SKAction.fadeOutWithDuration(0.4)]);
        let moveTitle = SKAction.moveBy(CGVector(dx: -titleChange, dy: 0), duration: 3.8);
        let moveArtist = SKAction.moveBy(CGVector(dx: -artistChange, dy: 0), duration: 3.8);
        let titleAction = SKAction.group([fadeText, moveTitle]);
        let artistAction = SKAction.group([fadeText, moveArtist]);
        let calculatingTiltAction = fadeText;
        let playSong = SKAction.runBlock({
            self.songPlayer.prepareToPlay();
            self.songPlayer.play();
        });
        let showField = SKAction.runBlock({
            self.dysc.alpha = 1;
//            self.highlight.alpha = 1;
            self.cursor.alpha = 1;
            self.mapData.scoreLabel.alpha = 1;
            self.mapData.accuracyLabel.alpha = 1;
        });
        
        titleNode.runAction(SKAction.sequence([titleAction, showField, playSong]));
        artistNode.runAction(artistAction);
        calculatingTiltNode.runAction(calculatingTiltAction);
        
        mapData.comboLabel.position = CGPoint(x: size.width/2, y: size.height/4);
        mapData.comboLabel.zPosition = 100;
        mapData.comboLabel.fontColor = UIColor.blackColor();
        mapData.judgmentLabel.position = CGPoint(x: size.width/2, y: size.height/3);
        mapData.judgmentLabel.zPosition = 100;
        mapData.judgmentLabel.fontColor = UIColor.blackColor();
        mapData.scoreLabel.position = CGPoint(x: size.width-10, y: size.height-35);
        mapData.scoreLabel.zPosition = 100;
        mapData.scoreLabel.fontColor = UIColor.blackColor();
        mapData.scoreLabel.alpha = 0;
        mapData.hitErrorLabel.position = CGPoint(x: 45, y: size.height/3);
        mapData.hitErrorLabel.zPosition = 100;
        mapData.hitErrorLabel.fontColor = UIColor.blackColor();
        mapData.accuracyLabel.position = CGPoint(x: 10, y: size.height-35);
        mapData.accuracyLabel.zPosition = 100;
        mapData.accuracyLabel.fontColor = UIColor.blackColor();
        mapData.accuracyLabel.alpha = 0;
        
        addButtons();
        addChild(dysc);
        addCursor();
        addChild(highlight);
        addChild(titleNode);
        addChild(artistNode);
        addChild(calculatingTiltNode);
        let dyscRadius = dysc.size.width/2;
        let noteWidth = dyscRadius - dyscRadius/sqrt(2) + dyscRadius/32;
        let noteHeight = dysc.size.height/sqrt(2);
        for note in mapData.notes {
            addChild(note);
            note.anchorPoint = CGPoint(x: 1.0, y: 0.5);
            note.position = dysc.position;
            note.size = CGSize(width: noteWidth, height: noteHeight);
            if let holdNote = note as? HoldNote {
                addChild(holdNote.pathNode);
            }
        }
        addChild(mapData.soundPlayer);
        addChild(mapData.comboLabel);
        addChild(mapData.judgmentLabel);
        addChild(mapData.scoreLabel);
        addChild(mapData.hitErrorLabel);
        addChild(mapData.accuracyLabel);
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

extension InGameScene: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        NSLog("Song finished");
        let endLabel: SKLabelNode = SKLabelNode(text: "Song Complete!");
        endLabel.fontColor = UIColor.blackColor();
        endLabel.fontName = "HelveticaNeue-Medium";
        endLabel.position = CGPoint(x: size.width/2, y: size.height*2/3);
        let hideField = SKAction.runBlock({
            self.dysc.alpha = 0;
            self.highlight.alpha = 0;
            self.cursor.alpha = 0;
        });
        let returnToSongSelect = SKAction.runBlock({
            self.viewController.performSegueWithIdentifier("backToSongSelect", sender: self.viewController);
        });
        let goToResults = SKAction.runBlock({
            let scene = ResultsScene(size: self.size, mapData: self.mapData);
            scene.viewController = self.viewController;
            self.viewController.quitButton.hidden = true;
            self.view!.presentScene(scene, transition: SKTransition.pushWithDirection(SKTransitionDirection.Left, duration: 1));
        });
        endLabel.runAction(SKAction.sequence([hideField, SKAction.waitForDuration(3), goToResults]));
        cursor.stopUpdates();
        
        addChild(endLabel);
    }
}
