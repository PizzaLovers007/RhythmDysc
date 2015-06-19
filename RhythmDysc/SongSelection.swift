//
//  SongSelection.swift
//  RhythmDysc
//
//  Created by MUser on 6/17/15.
//  Copyright (c) 2015 TynyLabs. All rights reserved.
//

import UIKit;
import SpriteKit;

class SongSelection: SKSpriteNode {
    
    let title: String;
    let artist: String;
    let maxBPM: Double;
    let titleNode: SKLabelNode;
    let artistNode: SKLabelNode;
    let bpmNode: SKLabelNode;
    let coverImageNode: SKSpriteNode;
    
    init(size: CGSize, title t: String, artist a: String, maxBPM b: Double) {
        title = t;
        artist = a;
        maxBPM = b;
        let texture = SKTexture(imageNamed: "SongSelectionBackground");
        titleNode = SKLabelNode(text: title);
        artistNode = SKLabelNode(text: artist);
        bpmNode = SKLabelNode(text: "\(maxBPM)");
        coverImageNode = SKSpriteNode(texture: SKTexture(imageNamed: title));
        super.init(texture: texture, color: UIColor.whiteColor(), size: size);
        anchorPoint = CGPoint(x: 0, y: 0);
        setupPositions();
    }
    
    required init?(coder aDecoder: NSCoder) {
        title = "";
        artist = "";
        maxBPM = 0;
        titleNode = SKLabelNode();
        artistNode = SKLabelNode();
        bpmNode = SKLabelNode();
        coverImageNode = SKSpriteNode();
        super.init(coder: aDecoder);
    }
    
    private func setupPositions() {
        let coverImageSize = CGSize(width: size.height-10, height: size.height-10);
        let bpmValueNode = SKLabelNode(text: "\(maxBPM)");
        let bpmTitleNode = SKLabelNode(text: "MAX BPM");
        coverImageNode.size = coverImageSize;
        coverImageNode.position = CGPoint(x: coverImageSize.width/2+5, y: coverImageSize.height/2+5);
        coverImageNode.alpha = 0.5;
        titleNode.fontName = "HelveticaNeue-Medium";
        titleNode.fontSize = size.height/4;
        titleNode.fontColor = UIColor.blackColor();
        titleNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left;
        titleNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center;
        titleNode.position = CGPoint(x: 15, y: size.height*3/4);
        titleNode.zPosition = 1;
        artistNode.fontName = "helveticaNeue";
        artistNode.fontSize = size.height/4;
        artistNode.fontColor = UIColor.blackColor();
        artistNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left;
        artistNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center;
        artistNode.position = CGPoint(x: 15, y: size.height/4);
        artistNode.zPosition = 1;
        bpmNode.fontName = "AvenirNextCondensed-Bold";
        bpmNode.fontSize = size.height/4;
        bpmNode.fontColor = UIColor.blackColor();
        bpmNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right;
        bpmNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top;
        bpmNode.position = CGPoint(x: size.width-15, y: size.height-15);
        bpmNode.zPosition = 1;
        addChild(coverImageNode);
        addChild(titleNode);
        addChild(artistNode);
        addChild(bpmNode);
    }
}
