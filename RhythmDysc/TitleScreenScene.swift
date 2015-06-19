//
//  TitleScreenScene.swift
//  RhythmDysc
//
//  Created by MUser on 6/18/15.
//  Copyright (c) 2015 TynyLabs. All rights reserved.
//

import UIKit;
import SpriteKit;

class TitleScreenScene: SKScene {
    
    let titleNode = SKLabelNode(text: "Rhythm Dysc");
    let playButton = SKShapeNode();
    let optionsButton = SKShapeNode();
    let helpButton = SKShapeNode();
    
    override init(size: CGSize) {
        super.init(size: size);
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func didMoveToView(view: SKView) {
        backgroundColor = UIColor.whiteColor();
        addTitle();
        addButtons();
    }
    
    override func update(currentTime: NSTimeInterval) {
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        for t in touches {
            let touch = t as! UITouch;
            let touchLocation = touch.locationInNode(self);
            let touchedNode = nodeAtPoint(touchLocation);
            if (touchedNode.name == "PlayGame") {
                self.scene?.view?.presentScene(SongSelectScene(size: size));
            }
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        
    }
    
    private func addTitle() {
        titleNode.position = CGPoint(x: size.width/2, y: size.height*3/4);
        titleNode.fontColor = UIColor.blackColor();
        titleNode.fontName = "HelveticaNeue-Bold";
        titleNode.fontSize = titleNode.fontSize*3/2;
        addChild(titleNode);
    }
    
    private func addButtons() {
        let playButtonRect = CGRect(origin: CGPoint(x: -size.width/4, y: -size.height/14), size: CGSize(width: size.width/2, height: size.height/7));
        let playButtonText = SKLabelNode(text: "Play Game");
        let playButtonPath = CGPathCreateMutable();
        CGPathAddRect(playButtonPath, nil, playButtonRect);
        playButtonText.fontName = "HelveticaNeue-Medium";
        playButtonText.fontColor = UIColor.blackColor();
        playButtonText.zPosition = 10;
        playButtonText.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center;
        playButtonText.name = "PlayGame";
        playButton.addChild(playButtonText);
        playButton.path = playButtonPath;
        playButton.position = CGPoint(x: size.width/2, y: size.height/2);
        playButton.fillColor = UIColor.redColor();
        playButton.name = "PlayGame";
        addChild(playButton);
    }
}
