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

enum NoteJudgment: Int {
    case MISS = 0;
    case GOOD = 1;
    case GREAT = 2;
    case PERFECT = 3;
    case HOLD = 4;
    case SLIP = 5;
}

class Note: SKSpriteNode {
    
    let direction: Int;
    let noteColor: Int;
    let timePoint: Int;
    let measure: Int;
    let beat: Double;
    var msHit: Int = 0;
    var msAppear: Int = 0;
    
    override var description: String {
        return "Note:[Direction: \(direction), Color: \(noteColor), Measure: \(measure), Beat: \(beat)]";
    }
    
    init() {
        direction = 0;
        noteColor = 0;
        timePoint = 0;
        measure = 0;
        beat = 0;
        super.init(texture: SKTexture(), color: UIColor.blueColor(), size: CGSize(width: 0,height: 0));
        alpha = 0;
    }
    
    init(direction dir: Int, color col: Int, timePoint tp: Int, measure meas: Int, beat bt: Double) {
        direction = dir;
        noteColor = col;
        timePoint = tp;
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
        alpha = 0;
    }

    required init?(coder aDecoder: NSCoder) {
        direction = 0;
        noteColor = 0;
        timePoint = 0;
        measure = 0;
        beat = 0;
        super.init(coder: aDecoder);
    }
    
    func setTiming(timePoint: TimingPoint, appearFor appear: Int) {
        let msPerBeat = 60000/timePoint.bpm;
        let beatsAfterTime = Double(timePoint.keySignature * (measure-1)) + beat-1;
        msHit = timePoint.time + Int(round(msPerBeat * beatsAfterTime));
        msAppear = msHit-appear;
    }
}