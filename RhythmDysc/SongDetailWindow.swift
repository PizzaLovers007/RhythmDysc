//
//  SongDetailWindow.swift
//  RhythmDysc
//
//  Created by MUser on 6/18/15.
//  Copyright (c) 2015 TynyLabs. All rights reserved.
//

import UIKit;
import SpriteKit;
import AVFoundation;

class SongDetailWindow: SKNode {
    
    let titleNode = SKLabelNode();
    let artistNode = SKLabelNode();
    let bpmNode = SKLabelNode();
    let backgroundNode = SKSpriteNode(texture: SKTexture(imageNamed: "SongDetailBackground"));
    let coverImageNode = SKSpriteNode();
    let twoSectorSelection = SKSpriteNode(texture: SKTexture(imageNamed: "2SectorSelection"));
    let fourSectorSelection = SKSpriteNode(texture: SKTexture(imageNamed: "4SectorSelection"));
    let eightSectorSelection = SKSpriteNode(texture: SKTexture(imageNamed: "8SectorSelection"));
    let easyDifficultySelection = SKSpriteNode(texture: SKTexture(imageNamed: "EasyDifficultySelection"));
    let normalDifficultySelection = SKSpriteNode(texture: SKTexture(imageNamed: "NormalDifficultySelection"));
    let hardDifficultySelection = SKSpriteNode(texture: SKTexture(imageNamed: "HardDifficultySelection"));
    let expertDifficultySelection = SKSpriteNode(texture: SKTexture(imageNamed: "ExpertDifficultySelection"));
    let startButton = SKSpriteNode(texture: SKTexture(imageNamed: "StartSongButton"));
    let cancelButton = SKSpriteNode(texture: SKTexture(imageNamed: "CancelButton"));
    var sectorSelections: [SKSpriteNode];
    var difficultySelections: [SKSpriteNode];
    var currSectorSelection: SKSpriteNode;
    var currDifficultySelection: SKSpriteNode;
    var touchedNode: SKSpriteNode?;
    var songURL: NSURL = NSURL();
    var audioPlayer: AVAudioPlayer! = nil;
    var previewTime: Double = 0;
    
    init(size: CGSize) {
        currSectorSelection = twoSectorSelection;
        currDifficultySelection = easyDifficultySelection;
        sectorSelections = [twoSectorSelection, fourSectorSelection, eightSectorSelection];
        difficultySelections = [easyDifficultySelection, normalDifficultySelection, hardDifficultySelection, expertDifficultySelection];
        super.init();
        name = "SongDetailWindow";
        hidden = true;
        setupPositions(size);
    }

    required init?(coder aDecoder: NSCoder) {
        currSectorSelection = twoSectorSelection;
        currDifficultySelection = easyDifficultySelection;
        sectorSelections = [twoSectorSelection, fourSectorSelection, eightSectorSelection];
        difficultySelections = [easyDifficultySelection, normalDifficultySelection, hardDifficultySelection, expertDifficultySelection];
        super.init(coder: aDecoder);
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch;
        let touchLocation = touch.locationInNode(self);
        for nextSelection in sectorSelections {
            if (nextSelection.containsPoint(touchLocation)) {
                touchedNode = nextSelection;
            }
        }
        for nextSelection in difficultySelections {
            if (nextSelection.containsPoint(touchLocation)) {
                touchedNode = nextSelection;
            }
        }
        if (cancelButton.containsPoint(touchLocation)) {
            touchedNode = cancelButton;
        } else if (startButton.containsPoint(touchLocation)) {
            touchedNode = startButton;
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch;
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch;
        let touchLocation = touch.locationInNode(self);
        for nextSelection in sectorSelections {
            if (nextSelection.containsPoint(touchLocation) && touchedNode == nextSelection) {
                currSectorSelection.zPosition = 5;
                currSectorSelection = nextSelection;
                currSectorSelection.zPosition = 20;
            }
        }
        for nextSelection in difficultySelections {
            if (nextSelection.containsPoint(touchLocation) && touchedNode == nextSelection) {
                currDifficultySelection.zPosition = 5;
                currDifficultySelection = nextSelection;
                currDifficultySelection.zPosition = 20;
            }
        }
        if (cancelButton.containsPoint(touchLocation) && touchedNode == cancelButton) {
            userInteractionEnabled = false;
            hidden = true;
            currSectorSelection.zPosition = 5;
            currDifficultySelection.zPosition = 5;
            currSectorSelection = twoSectorSelection;
            currDifficultySelection = easyDifficultySelection;
            twoSectorSelection.zPosition = 20;
            easyDifficultySelection.zPosition = 20;
            audioPlayer.stop();
        } else if (startButton.containsPoint(touchLocation) && touchedNode == startButton) {
            audioPlayer.stop();
            let searchTitle = titleNode.text.stringByReplacingOccurrencesOfString(" ", withString: "");
            let mapName = "\(searchTitle)-\(currDifficultySelection.name!)-\(currSectorSelection.name!)";
            let mapURL = NSBundle.mainBundle().URLForResource(mapName, withExtension: "dmp");
            let mapData = MapReader.readFile(mapURL!);
            scene?.view?.presentScene(InGameScene(size: (parent! as! SKScene).size, songURL: songURL, mapData: mapData));
        }
    }
    
    func setSongSelection(selection: SongSelection) {
        titleNode.text = selection.title;
        artistNode.text = selection.artist;
        bpmNode.text = "MAX BPM: \(selection.maxBPM)";
        coverImageNode.texture = selection.coverImageNode.texture;
        let searchTitle = selection.title.stringByReplacingOccurrencesOfString(" ", withString: "");
        let mapURL = NSBundle.mainBundle().URLForResource("\(searchTitle)-easy-4", withExtension: "dmp")!;
        let mapData = MapReader.readFile(mapURL);
        songURL = NSBundle.mainBundle().URLForResource(searchTitle, withExtension: "mp3")!;
        var error: NSError?;
        audioPlayer = AVAudioPlayer(contentsOfURL: songURL, error: &error);
        if (error != nil) {
            NSLog(error!.description);
        }
        audioPlayer.prepareToPlay();
        previewTime = Double(mapData.preview)/1000;
        audioPlayer.currentTime = previewTime;
    }
    
    private func setupPositions(size: CGSize) {
        position = CGPoint(x: size.width/2, y: size.height/2);
        backgroundNode.size = size;
        backgroundNode.zPosition = 10;
        let coverImageSize = CGSize(width: size.width/2, height: size.width/2);
        coverImageNode.size = coverImageSize;
        coverImageNode.position = CGPoint(x: 0, y: size.height*3/10);
        coverImageNode.zPosition = 20;
        titleNode.fontName = "HelveticaNeue-Medium";
        titleNode.fontSize = titleNode.fontSize*5/4;
        titleNode.fontColor = UIColor.whiteColor();
        titleNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center;
        titleNode.position = CGPoint(x: 0, y: size.height/8.5);
        titleNode.zPosition = 20;
        artistNode.fontName = "HelveticaNeue-Light";
        artistNode.fontSize = artistNode.fontSize*3/4;
        artistNode.fontColor = UIColor.whiteColor();
        artistNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center;
        artistNode.position = CGPoint(x: 0, y: size.height/18);
        artistNode.zPosition = 20;
        bpmNode.fontName = "HelveticaNeue-Bold";
        bpmNode.fontSize = bpmNode.fontSize*3/4;
        bpmNode.fontColor = UIColor.whiteColor();
        bpmNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center;
        bpmNode.position = CGPoint(x: 0, y: 0);
        bpmNode.zPosition = 20;
        
        let sectorButtonSize = CGSize(width: size.width/5, height: size.width/5);
        twoSectorSelection.size = sectorButtonSize;
        twoSectorSelection.position = CGPoint(x: -sectorButtonSize.width*3/2, y: -size.height/8);
        twoSectorSelection.zPosition = 5;
        twoSectorSelection.name = "2";
        fourSectorSelection.size = sectorButtonSize;
        fourSectorSelection.position = CGPoint(x: 0, y: -size.height/8);
        fourSectorSelection.zPosition = 5;
        fourSectorSelection.name = "4";
        eightSectorSelection.size = sectorButtonSize;
        eightSectorSelection.position = CGPoint(x: sectorButtonSize.width*3/2, y: -size.height/8);
        eightSectorSelection.zPosition = 5;
        eightSectorSelection.name = "8";
        
        let difficultyButtonSize = CGSize(width: size.width/13*2, height: size.width/13*2);
        easyDifficultySelection.size = difficultyButtonSize;
        easyDifficultySelection.position = CGPoint(x: difficultyButtonSize.width-size.width/2, y: -size.height/4);
        easyDifficultySelection.zPosition = 5;
        easyDifficultySelection.name = "easy";
        normalDifficultySelection.size = difficultyButtonSize;
        normalDifficultySelection.position = CGPoint(x: -difficultyButtonSize.width*3/4, y: -size.height/4);
        normalDifficultySelection.zPosition = 5;
        normalDifficultySelection.name = "normal";
        hardDifficultySelection.size = difficultyButtonSize;
        hardDifficultySelection.position = CGPoint(x: difficultyButtonSize.width*3/4, y: -size.height/4);
        hardDifficultySelection.zPosition = 5;
        hardDifficultySelection.name = "hard";
        expertDifficultySelection.size = difficultyButtonSize;
        expertDifficultySelection.position = CGPoint(x: size.width/2-difficultyButtonSize.width, y: -size.height/4);
        expertDifficultySelection.zPosition = 5;
        expertDifficultySelection.name = "expert";
        
        currSectorSelection.zPosition = 20;
        currDifficultySelection.zPosition = 20;
        
        let actionButtonSize = CGSize(width: size.width/3, height: size.width/9);
        startButton.size = actionButtonSize;
        startButton.position = CGPoint(x: size.width/4, y: -size.height*7/16);
        startButton.zPosition = 20;
        cancelButton.size = actionButtonSize;
        cancelButton.position = CGPoint(x: -size.width/4, y: -size.height*7/16);
        cancelButton.zPosition = 20;
        
        addChild(startButton);
        addChild(cancelButton);
        addChild(backgroundNode);
        addChild(coverImageNode);
        addChild(titleNode);
        addChild(artistNode);
        addChild(bpmNode);
        addChild(twoSectorSelection);
        addChild(fourSectorSelection);
        addChild(eightSectorSelection);
        addChild(easyDifficultySelection);
        addChild(normalDifficultySelection);
        addChild(hardDifficultySelection);
        addChild(expertDifficultySelection);
    }
}
