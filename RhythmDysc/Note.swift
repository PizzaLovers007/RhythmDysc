//
//  Note.swift
//  RhythmDysc
//
//  Created by MUser on 6/8/15.
//  Copyright (c) 2015 TynyLabs. All rights reserved.
//

import UIKit;
import SpriteKit;

struct NoteColor {
    static let RED = 0;
    static let GREEN = 1;
    static let BLUE = 2;
}

struct NoteDirection {
    static let RIGHT = 0;
    static let UP = 1;
    static let LEFT = 2;
    static let DOWN = 3;
}

class Note: SKSpriteNode {
    
    let direction: Int;
    let noteColor: Int;
    let measure: Int;
    let beat: Double;
    
    override var description: String {
        return "Note:[Direction: \(direction), Color: \(noteColor), Measure: \(measure), Beat: \(beat)]";
    }
    
    init() {
        direction = 0;
        noteColor = 0;
        measure = 0;
        beat = 0;
        super.init(texture: SKTexture(), color: UIColor.blueColor(), size: CGSize(width: 0,height: 0));
    }
    
    init(direction dir: Int, color col: Int, measure meas: Int, beat bt: Double) {
        direction = dir;
        noteColor = col;
        measure = meas;
        beat = bt;
        let imageName: String;
        switch (noteColor) {
        case NoteColor.RED:
            break;
        case NoteColor.GREEN:
            break;
        case NoteColor.BLUE:
            break;
        default:
            break;
        }
        super.init(texture: SKTexture(), color: UIColor.blueColor(), size: CGSize(width: 0,height: 0));
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
