//
//  ResultsScene.swift
//  RhythmDysc
//
//  Created by MUser on 7/29/15.
//  Copyright (c) 2015 TynyLabs. All rights reserved.
//

import UIKit;
import SpriteKit;
import AVFoundation;

class ResultsScene: SKScene {
    
    let mapData: DyscMap;
    let scoreLabel = SKLabelNode();
    let accuracyLabel = SKLabelNode();
    let gradeLabel = SKLabelNode();
    let comboLabel = SKLabelNode();
    let perfectLabel = SKLabelNode();
    let greatLabel = SKLabelNode();
    let goodLabel = SKLabelNode();
    let missLabel = SKLabelNode();
    let holdLabel = SKLabelNode();
    let slipLabel = SKLabelNode();
    let quitButton = SKSpriteNode(imageNamed: "ReturnToSongSelectButton");
    var isHoldingQuitButton = false;
    var viewController: GameViewController!;
    
    init(size: CGSize, mapData: DyscMap) {
        self.mapData = mapData;
        super.init(size: size);
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    
    override func didMoveToView(view: SKView) {
        NSLog("Entered Results Scene");
        self.backgroundColor = UIColor.whiteColor();
        initializeObjects();
        performActions();
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch;
        let touchLocation = touch.locationInNode(self);
        if (quitButton.containsPoint(touchLocation)) {
            isHoldingQuitButton = true;
            quitButton.colorBlendFactor = 0.6;
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch;
        let touchLocation = touch.locationInNode(self);
        if (quitButton.containsPoint(touchLocation)) {
            viewController.performSegueWithIdentifier("backToSongSelect", sender: self.viewController);
        } else {
            quitButton.colorBlendFactor = 0;
        }
    }
    
    private func initializeObjects() {
        let resultsLabel = SKLabelNode(text: "Results");
        resultsLabel.fontName = "HelveticaNeue-Medium";
        resultsLabel.fontColor = UIColor.blackColor();
        resultsLabel.position = CGPoint(x: size.width/2, y:size.height*5/6);
        scoreLabel.text = mapData.scoreLabel.text;
        scoreLabel.position = CGPoint(x: size.width/2, y: size.height*3/4);
        scoreLabel.fontColor = UIColor.blackColor();
        scoreLabel.fontName = "HelveticaNeue-Light";
        scoreLabel.alpha = 0;
        accuracyLabel.text = mapData.accuracyLabel.text;
        accuracyLabel.position = CGPoint(x: size.width/2, y: scoreLabel.position.y-40);
        accuracyLabel.fontColor = UIColor.blackColor();
        accuracyLabel.fontName = "HelveticaNeue-Light";
        accuracyLabel.alpha = 0;
        gradeLabel.text = "Your Grade: \(getGrade())";
        gradeLabel.position = CGPoint(x: size.width/2, y: scoreLabel.position.y-80);
        gradeLabel.fontColor = UIColor.blackColor();
        gradeLabel.fontName = "HelveticaNeue-Light";
        gradeLabel.alpha = 0;
        comboLabel.text = "Max combo: \(mapData.maxCombo)";
        comboLabel.position = CGPoint(x: size.width/2, y: scoreLabel.position.y-120);
        comboLabel.fontColor = UIColor.blackColor();
        comboLabel.fontName = "HelveticaNeue-Light";
        comboLabel.alpha = 0;
        perfectLabel.text = String(format: "Perfect: %d", mapData.hitStats[NoteJudgment.PERFECT]!);
        perfectLabel.position = CGPoint(x: size.width/2, y: scoreLabel.position.y-180);
        perfectLabel.fontColor = UIColor.blackColor();
        perfectLabel.alpha = 0;
        greatLabel.text = String(format: "Great: %d", mapData.hitStats[NoteJudgment.GREAT]!);
        greatLabel.position = CGPoint(x: size.width/2, y: scoreLabel.position.y-220);
        greatLabel.fontColor = UIColor.blackColor();
        greatLabel.alpha = 0;
        goodLabel.text = String(format: "Good: %d", mapData.hitStats[NoteJudgment.GOOD]!);
        goodLabel.position = CGPoint(x: size.width/2, y: scoreLabel.position.y-260);
        goodLabel.fontColor = UIColor.blackColor();
        goodLabel.alpha = 0;
        missLabel.text = String(format: "Miss: %d", mapData.hitStats[NoteJudgment.MISS]!);
        missLabel.position = CGPoint(x: size.width/2, y: scoreLabel.position.y-300);
        missLabel.fontColor = UIColor.blackColor();
        missLabel.alpha = 0;
        holdLabel.text = String(format: "Hold: %d", mapData.hitStats[NoteJudgment.HOLD]!);
        holdLabel.position = CGPoint(x: size.width/2, y: scoreLabel.position.y-340);
        holdLabel.fontColor = UIColor.blackColor();
        holdLabel.alpha = 0;
        slipLabel.text = String(format: "Slip: %d", mapData.hitStats[NoteJudgment.SLIP]!);
        slipLabel.position = CGPoint(x: size.width/2, y: scoreLabel.position.y-380);
        slipLabel.fontColor = UIColor.blackColor();
        slipLabel.alpha = 0;
        
        quitButton.size = CGSize(width: size.width-20, height: size.height/10);
        quitButton.position = CGPoint(x: size.width/2, y: quitButton.size.height/2+10);
        quitButton.color = UIColor.blackColor();
        
        addChild(resultsLabel);
        addChild(scoreLabel);
        addChild(accuracyLabel);
        addChild(gradeLabel);
        addChild(comboLabel);
        addChild(perfectLabel);
        addChild(greatLabel);
        addChild(goodLabel);
        addChild(missLabel);
        addChild(holdLabel);
        addChild(slipLabel);
        addChild(quitButton);
    }
    
    private func performActions() {
        scoreLabel.runAction(SKAction.fadeInWithDuration(0.1));
        accuracyLabel.runAction(SKAction.sequence([SKAction.waitForDuration(0.1), SKAction.fadeInWithDuration(0.1)]));
        gradeLabel.runAction(SKAction.sequence([SKAction.waitForDuration(0.2), SKAction.fadeInWithDuration(0.1)]));
        comboLabel.runAction(SKAction.sequence([SKAction.waitForDuration(0.3), SKAction.fadeInWithDuration(0.1)]));
        perfectLabel.runAction(SKAction.sequence([SKAction.waitForDuration(0.4), SKAction.fadeInWithDuration(0.1)]));
        greatLabel.runAction(SKAction.sequence([SKAction.waitForDuration(0.5), SKAction.fadeInWithDuration(0.1)]));
        goodLabel.runAction(SKAction.sequence([SKAction.waitForDuration(0.6), SKAction.fadeInWithDuration(0.1)]));
        missLabel.runAction(SKAction.sequence([SKAction.waitForDuration(0.7), SKAction.fadeInWithDuration(0.1)]));
        holdLabel.runAction(SKAction.sequence([SKAction.waitForDuration(0.8), SKAction.fadeInWithDuration(0.1)]));
        slipLabel.runAction(SKAction.sequence([SKAction.waitForDuration(0.9), SKAction.fadeInWithDuration(0.1)]));
    }
    
    private func getGrade() -> String {
        if (mapData.accuracy == 100) {
            return "SS";
        } else if (mapData.accuracy >= 95) {
            return "S";
        } else if (mapData.accuracy >= 90) {
            return "A";
        } else if (mapData.accuracy >= 80) {
            return "B";
        } else if (mapData.accuracy >= 75) {
            return "C";
        } else if (mapData.accuracy >= 70) {
            return "D";
        } else {
            return "F";
        }
    }
}
