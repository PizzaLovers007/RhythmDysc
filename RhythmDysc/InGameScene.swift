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
    let pauseButton = SKSpriteNode(imageNamed: "PauseButton");
    let continueButton = SKLabelNode(text: "Continue");
    let quitButton = SKLabelNode(text: "Quit");
    let cursor = Cursor();
    let highlight = SKSpriteNode(imageNamed: "4SectorBlueArc");
    let dysc = SKSpriteNode(imageNamed: "4SectorDysc");
    let centerSprite = SKSpriteNode(imageNamed: "Cursor");
    let mapData: DyscMap;
    var songPlayer: AVAudioPlayer! = nil;
    var redDown: Bool = false;
    var greenDown: Bool = false;
    var blueDown: Bool = false;
    var pauseDown: Bool = false;
    var songIsPaused: Bool = false;
    var prevTime: NSTimeInterval = -1;
    var startTime: NSTimeInterval = 0;
    weak var viewController: GameViewController!;
    var hideFieldAction: SKAction!;
    var showFieldAction: SKAction!;
    var hidePauseMenu: SKAction!;
    var showPauseMenu: SKAction!;
    
    init(size: CGSize, songURL: NSURL, mapData data: DyscMap) {
        do {
            songPlayer = try AVAudioPlayer(contentsOfURL: songURL);
        } catch {
            print(error);
        }
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
//        let deltaTime: Double = (currentTime - prevTime) * 1000;
        prevTime = currentTime;
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for t in touches {
            let touch = t;
            let touchLocation = touch.locationInNode(self);
            if (!redDown && redButton.containsPoint(touchLocation)) {
                NSLog("Red button pressed");
                redDown = true;
                redButton.pressButton();
                if (songPlayer.playing) {
                    mapData.updateButton(ButtonColor.RED, isPressed: true, songTime: songPlayer.currentTime);
                }
            } else if (!greenDown && greenButton.containsPoint(touchLocation)) {
                NSLog("Green button pressed");
                greenDown = true;
                greenButton.pressButton();
                if (songPlayer.playing) {
                    mapData.updateButton(ButtonColor.GREEN, isPressed: true, songTime: songPlayer.currentTime);
                }
            } else if (!blueDown && blueButton.containsPoint(touchLocation)) {
                NSLog("Blue button pressed");
                blueDown = true;
                blueButton.pressButton();
                if (songPlayer.playing) {
                    mapData.updateButton(ButtonColor.BLUE, isPressed: true, songTime: songPlayer.currentTime);
                }
            } else if (pauseButton.containsPoint(touchLocation) && pauseButton.alpha > 0) {
                pauseDown = true;
            } else if (songIsPaused && continueButton.containsPoint(touchLocation)) {
                runAction(SKAction.group([showFieldAction, hidePauseMenu]));
                mapData.updateButton(ButtonColor.RED, isPressed: redDown, songTime: songPlayer.currentTime);
                mapData.updateButton(ButtonColor.GREEN, isPressed: greenDown, songTime: songPlayer.currentTime);
                mapData.updateButton(ButtonColor.BLUE, isPressed: blueDown, songTime: songPlayer.currentTime);
                songPlayer.play();
                songIsPaused = false;
            } else if (songIsPaused && quitButton.containsPoint(touchLocation)) {
                viewController.performSegueWithIdentifier("backToSongSelect", sender: viewController);
                hideFieldAction = nil;
                showFieldAction = nil;
                hidePauseMenu = nil;
                showPauseMenu = nil;
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for t in touches {
            let touch = t;
            let touchLocation = touch.locationInNode(self);
            let prevTouchLocation = touch.previousLocationInNode(self);
            if (redDown && !redButton.containsPoint(touchLocation) && redButton.containsPoint(prevTouchLocation)) {
                NSLog("Red button released");
                redDown = false;
                redButton.releaseButton();
                if (songPlayer.playing) {
                    mapData.updateButton(ButtonColor.RED, isPressed: false, songTime: songPlayer.currentTime);
                }
            } else if (greenDown && !greenButton.containsPoint(touchLocation) && greenButton.containsPoint(prevTouchLocation)) {
                NSLog("Green button released");
                greenDown = false;
                greenButton.releaseButton();
                if (songPlayer.playing) {
                    mapData.updateButton(ButtonColor.GREEN, isPressed: false, songTime: songPlayer.currentTime);
                }
            } else if (blueDown && !blueButton.containsPoint(touchLocation) && blueButton.containsPoint(prevTouchLocation)) {
                NSLog("Blue button released");
                blueDown = false;
                blueButton.releaseButton();
                if (songPlayer.playing) {
                    mapData.updateButton(ButtonColor.BLUE, isPressed: false, songTime: songPlayer.currentTime);
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for t in touches {
            let touch = t;
            let touchLocation = touch.locationInNode(self);
            if (redButton.containsPoint(touchLocation) && redDown) {
                NSLog("Red button released");
                redDown = false;
                redButton.releaseButton();
                if (songPlayer.playing) {
                    mapData.updateButton(ButtonColor.RED, isPressed: false, songTime: songPlayer.currentTime);
                }
            } else if (greenButton.containsPoint(touchLocation) && greenDown) {
                NSLog("Green button released");
                greenDown = false;
                greenButton.releaseButton();
                if (songPlayer.playing) {
                    mapData.updateButton(ButtonColor.GREEN, isPressed: false, songTime: songPlayer.currentTime);
                }
            } else if (blueButton.containsPoint(touchLocation) && blueDown) {
                NSLog("Blue button released");
                blueDown = false;
                blueButton.releaseButton();
                if (songPlayer.playing) {
                    mapData.updateButton(ButtonColor.BLUE, isPressed: false, songTime: songPlayer.currentTime);
                }
            } else if (pauseButton.containsPoint(touchLocation) && pauseDown) {
                if (songPlayer.playing) {
                    runAction(SKAction.group([hideFieldAction, showPauseMenu]));
                    songPlayer.pause();
                    songIsPaused = true;
                }
            }
        }
        pauseDown = false;
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
        let titleChange = max(CGFloat(mapData.title.length*3), 40);
        let artistChange = max(CGFloat(mapData.artist.length*3), 40);
        
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
        calculatingTiltNode.position = CGPoint(x: size.width/2, y: size.width/3+40);
        calculatingTiltNode.fontColor = SKColor.blackColor();
        calculatingTiltNode.fontSize = calculatingTiltNode.fontSize/2;
        calculatingTiltNode.fontName = "HelveticaNeue-Medium";
        let pausedNode = SKLabelNode(text: "Paused");
        pausedNode.alpha = 0;
        pausedNode.position = CGPoint(x: size.width/2, y: size.height*2/3);
        pausedNode.fontColor = SKColor.blackColor();
        pausedNode.fontName = "HelveticaNeue-Medium";
        
        NSLog("\(size)");
        
        pauseButton.size = CGSize(width: size.width/10, height: size.width/10);
        pauseButton.position = CGPoint(x: size.width/2, y: size.height-pauseButton.size.height/2-5);
        pauseButton.alpha = 0;
        pauseButton.zPosition = 100;
        
        continueButton.alpha = 0;
        continueButton.position = CGPoint(x: size.width/2, y: size.height/2);
        continueButton.fontColor = SKColor.blackColor();
        quitButton.alpha = 0;
        quitButton.position = CGPoint(x: size.width/2, y: size.height/2-50);
        quitButton.fontColor = SKColor.blackColor();
        
        dysc.size = CGSize(width: size.height/2, height: size.height/2);
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
        showFieldAction = SKAction.runBlock({
            self.dysc.alpha = 1;
//            self.highlight.alpha = 1;
            self.cursor.alpha = 1;
            self.mapData.scoreLabel.alpha = 1;
            self.mapData.accuracyLabel.alpha = 1;
            self.mapData.comboLabel.alpha = 1;
            self.mapData.hitErrorLabel.alpha = 1;
            self.pauseButton.alpha = 1;
            for note in self.mapData.notes {
                if (!note.hasAppeared) {
                    break;
                }
                if let holdNote = note as? HoldNote {
                    holdNote.pathNode.alpha = 1;
                    if (!holdNote.hasHit) {
                        holdNote.alpha = 1;
                    }
                } else {
                    note.alpha = 1;
                }
            }
        });
        hideFieldAction = SKAction.runBlock({
            self.dysc.alpha = 0;
            //            self.highlight.alpha = 0;
            self.cursor.alpha = 0;
            self.mapData.scoreLabel.alpha = 0;
            self.mapData.accuracyLabel.alpha = 0;
            self.mapData.comboLabel.alpha = 0;
            self.mapData.judgmentLabel.alpha = 0;
            self.mapData.hitErrorLabel.alpha = 0;
            self.pauseButton.alpha = 0;
            for note in self.mapData.notes {
                if (!note.hasAppeared) {
                    break;
                }
                if let holdNote = note as? HoldNote {
                    holdNote.pathNode.alpha = 0;
                }
                note.alpha = 0;
            }
        });
        showPauseMenu = SKAction.runBlock({
            pausedNode.alpha = 1;
            self.continueButton.alpha = 1;
            self.quitButton.alpha = 1;
        });
        hidePauseMenu = SKAction.runBlock({
            pausedNode.alpha = 0;
            self.continueButton.alpha = 0;
            self.quitButton.alpha = 0;
        });
        
        titleNode.runAction(SKAction.sequence([titleAction, showFieldAction, playSong]));
        artistNode.runAction(artistAction);
        calculatingTiltNode.runAction(calculatingTiltAction);
        
        mapData.comboLabel.position = CGPoint(x: size.width/2, y: size.height/4);
        mapData.comboLabel.zPosition = 100;
        mapData.comboLabel.fontColor = UIColor.blackColor();
        mapData.judgmentLabel.position = CGPoint(x: size.width/2, y: size.height/3);
        mapData.judgmentLabel.zPosition = 100;
        mapData.judgmentLabel.fontColor = UIColor.blackColor();
        mapData.scoreLabel.position = CGPoint(x: size.width-10, y: size.height-10);
        mapData.scoreLabel.zPosition = 100;
        mapData.scoreLabel.fontColor = UIColor.blackColor();
        mapData.scoreLabel.fontSize = 32/375*size.width;
        mapData.scoreLabel.alpha = 0;
        mapData.hitErrorLabel.position = CGPoint(x: 45, y: size.height/3);
        mapData.hitErrorLabel.zPosition = 100;
        mapData.hitErrorLabel.fontColor = UIColor.blackColor();
        mapData.accuracyLabel.position = CGPoint(x: 10, y: size.height-10);
        mapData.accuracyLabel.zPosition = 100;
        mapData.accuracyLabel.fontColor = UIColor.blackColor();
        mapData.accuracyLabel.fontSize = 32/375*size.width;
        mapData.accuracyLabel.alpha = 0;
        
        addButtons();
        addChild(pauseButton);
        addChild(dysc);
        addCursor();
        addChild(highlight);
        addChild(titleNode);
        addChild(artistNode);
        addChild(calculatingTiltNode);
        addChild(pausedNode);
        addChild(continueButton);
        addChild(quitButton);
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
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
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
//        let returnToSongSelect = SKAction.runBlock({
//            self.viewController.performSegueWithIdentifier("backToSongSelect", sender: self.viewController);
//        });
        let goToResults = SKAction.runBlock({
            let scene = ResultsScene(size: self.size, mapData: self.mapData);
            scene.viewController = self.viewController;
            self.view!.presentScene(scene, transition: SKTransition.pushWithDirection(SKTransitionDirection.Left, duration: 1));
            self.hideFieldAction = nil;
            self.showFieldAction = nil;
            self.hidePauseMenu = nil;
            self.showPauseMenu = nil;
        });
        endLabel.runAction(SKAction.sequence([hideField, SKAction.waitForDuration(3), goToResults]));
        cursor.stopUpdates();
        
        addChild(endLabel);
    }
}

extension String {
    var length : Int {
        return self.characters.count;
    }
}
