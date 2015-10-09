//
//  ResultsScene.swift
//  RhythmDysc
//
//  Created by MUser on 7/29/15.
//  Copyright (c) 2015 TynyLabs. All rights reserved.
//

import UIKit;
import SpriteKit;
import CoreData;

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
        
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
        let context: NSManagedObjectContext = appDel.managedObjectContext!;
        
        let entity = NSEntityDescription.entityForName("Scores", inManagedObjectContext: context);
        
        let titlePredicate = NSPredicate(format: "songTitle = %@", mapData.title);
        let difficultyPredicate = NSPredicate(format: "difficulty = %d", mapData.approach);
        
        let request = NSFetchRequest(entityName: "Scores");
        request.returnsObjectsAsFaults = false;
        request.predicate = NSCompoundPredicate.andPredicateWithSubpredicates([titlePredicate, difficultyPredicate]);
        
        let oldScore = context.executeFetchRequest(request, error: nil)?.first as! SongScore?;
        if (oldScore == nil) {
            let newScore = SongScore(entity: entity!, insertIntoManagedObjectContext: context);
            newScore.songTitle = mapData.title;
            newScore.sectors = NSNumber(integer: mapData.sector);
            newScore.difficulty = NSNumber(integer: mapData.approach);
            newScore.grade = getGrade();
            newScore.score = NSNumber(integer: mapData.score);
            newScore.accuracy = NSNumber(floatLiteral: mapData.accuracy);
            newScore.maxCombo = NSNumber(integer: mapData.maxCombo);
            
            context.save(nil);
        } else if (oldScore != nil && mapData.score > oldScore?.score.integerValue) {
            let newScore = oldScore!;
            newScore.songTitle = mapData.title;
            newScore.sectors = NSNumber(integer: mapData.sector);
            newScore.difficulty = NSNumber(integer: mapData.approach);
            newScore.grade = getGrade();
            newScore.score = NSNumber(integer: mapData.score);
            newScore.accuracy = NSNumber(floatLiteral: mapData.accuracy);
            newScore.maxCombo = NSNumber(integer: mapData.maxCombo);
            
            context.save(nil);
        }
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
        let newFontSize = 32/667*size.height;
        scoreLabel.fontSize = newFontSize;
        accuracyLabel.fontSize = newFontSize;
        gradeLabel.fontSize = newFontSize;
        comboLabel.fontSize = newFontSize;
        perfectLabel.fontSize = newFontSize;
        greatLabel.fontSize = newFontSize;
        goodLabel.fontSize = newFontSize;
        missLabel.fontSize = newFontSize;
        holdLabel.fontSize = newFontSize;
        slipLabel.fontSize = newFontSize;
        let space = 40/32*newFontSize;
        
        let resultsLabel = SKLabelNode(text: "Results");
        resultsLabel.fontName = "HelveticaNeue-Medium";
        resultsLabel.fontColor = UIColor.blackColor();
        resultsLabel.fontSize = newFontSize*4/3;
        resultsLabel.position = CGPoint(x: size.width/2, y:size.height*5/6);
        scoreLabel.text = mapData.scoreLabel.text;
        scoreLabel.position = CGPoint(x: size.width/2, y: size.height*3/4);
        scoreLabel.fontColor = UIColor.blackColor();
        scoreLabel.fontName = "HelveticaNeue-Light";
        scoreLabel.alpha = 0;
        accuracyLabel.text = mapData.accuracyLabel.text;
        accuracyLabel.position = CGPoint(x: size.width/2, y: scoreLabel.position.y-space);
        accuracyLabel.fontColor = UIColor.blackColor();
        accuracyLabel.fontName = "HelveticaNeue-Light";
        accuracyLabel.alpha = 0;
        gradeLabel.text = "Your Grade: \(getGrade())";
        gradeLabel.position = CGPoint(x: size.width/2, y: scoreLabel.position.y-space*2);
        gradeLabel.fontColor = UIColor.blackColor();
        gradeLabel.fontName = "HelveticaNeue-Light";
        gradeLabel.alpha = 0;
        comboLabel.text = "Max combo: \(mapData.maxCombo)";
        comboLabel.position = CGPoint(x: size.width/2, y: scoreLabel.position.y-space*3);
        comboLabel.fontColor = UIColor.blackColor();
        comboLabel.fontName = "HelveticaNeue-Light";
        comboLabel.alpha = 0;
        perfectLabel.text = String(format: "Perfect: %d", mapData.hitStats[NoteJudgment.PERFECT]!);
        perfectLabel.position = CGPoint(x: size.width/2, y: scoreLabel.position.y-space*9/2);
        perfectLabel.fontColor = UIColor.blackColor();
        perfectLabel.alpha = 0;
        greatLabel.text = String(format: "Great: %d", mapData.hitStats[NoteJudgment.GREAT]!);
        greatLabel.position = CGPoint(x: size.width/2, y: scoreLabel.position.y-space*11/2);
        greatLabel.fontColor = UIColor.blackColor();
        greatLabel.alpha = 0;
        goodLabel.text = String(format: "Good: %d", mapData.hitStats[NoteJudgment.GOOD]!);
        goodLabel.position = CGPoint(x: size.width/2, y: scoreLabel.position.y-space*13/2);
        goodLabel.fontColor = UIColor.blackColor();
        goodLabel.alpha = 0;
        missLabel.text = String(format: "Miss: %d", mapData.hitStats[NoteJudgment.MISS]!);
        missLabel.position = CGPoint(x: size.width/2, y: scoreLabel.position.y-space*15/2);
        missLabel.fontColor = UIColor.blackColor();
        missLabel.alpha = 0;
        holdLabel.text = String(format: "Hold: %d", mapData.hitStats[NoteJudgment.HOLD]!);
        holdLabel.position = CGPoint(x: size.width/2, y: scoreLabel.position.y-space*17/2);
        holdLabel.fontColor = UIColor.blackColor();
        holdLabel.alpha = 0;
        slipLabel.text = String(format: "Slip: %d", mapData.hitStats[NoteJudgment.SLIP]!);
        slipLabel.position = CGPoint(x: size.width/2, y: scoreLabel.position.y-space*19/2);
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
