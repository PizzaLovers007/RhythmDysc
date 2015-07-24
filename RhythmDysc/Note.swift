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
    static let BLUE = 0;
    static let GREEN = 1;
    static let RED = 2;
}

struct SparkColor {
    static let BLUE = UIColor(red: 0, green: 0.2, blue: 1, alpha: 1);
    static let GREEN = UIColor(red: 0, green: 1, blue: 0, alpha: 1);
    static let RED = UIColor(red: 1, green: 0, blue: 0, alpha: 1);
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
    var hasAppeared = false;
    
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
        super.init(texture: SKTexture(), color: UIColor.blueColor(), size: CGSize(width: 0,height: 0));
        switch (noteColor) {
        case NoteColor.RED:
            color = SparkColor.RED;
            break;
        case NoteColor.GREEN:
            color = SparkColor.GREEN;
            break;
        case NoteColor.BLUE:
            color = SparkColor.BLUE;
            break;
        default:
            break;
        }
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
        let beatsAfterTime = Double(timePoint.keySignature * (measure-1)) + beat-1;
        msHit = timePoint.time + Int(round(timePoint.msPerBeat * beatsAfterTime));
        msAppear = msHit-appear;
    }
    
    func getPositionFraction(currTime msCurrTime: Int) -> Double {
        let currTime: Double = Double(msCurrTime)/1000;
        let appearTime: Double = Double(msAppear)/1000;
        let hitTime: Double = Double(msHit)/1000;
        return min(2, max(0, (currTime - appearTime) / (hitTime - appearTime)));
    }
}
