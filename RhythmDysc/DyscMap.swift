//
//  DyscMap.swift
//  RhythmDysc
//
//  Created by MUser on 6/5/15.
//  Copyright (c) 2015 TynyLabs. All rights reserved.
//

import UIKit;
import SpriteKit;

class DyscMap: NSObject {

    let title: String;
    let artist: String;
    let difficulty: Int;
    let approach: Int;
    let sector: Int;
    let offset: Int;
    let perfectRange: [Int] = [80, 60, 40, 20];
    let judgementDifference: [Int] = [55, 50, 45, 40];
    let msAppear: [Int] = [1500, 1200, 900, 600];
    var timingPoints: [TimingPoint] = [TimingPoint]();
    var notes: [Note] = [Note]();
    var prevSongTime: Int = 0;
    var score: Int = 0;
    var combo: Int = 0;
    var hitStats: [NoteJudgment: Int] = [NoteJudgment: Int]();
    var lastHoldCycle: Int = 0;
    
    override var description: String {
        var result: String = "";
        for note in notes {
            result += "\(note.description)\n";
        }
        return result.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet());
    }
    
    override init() {
        title = "";
        artist = "";
        difficulty = 0;
        approach = 0;
        sector = 0;
        offset = 0;
        super.init();
    }
    
    init(generalInfo: [String: String]) {
        title = generalInfo["title"]!;
        artist = generalInfo["artist"]!;
        difficulty = generalInfo["difficulty"]!.toInt()!;
        approach = generalInfo["approach"]!.toInt()!;
        sector = generalInfo["sector"]!.toInt()!;
        offset = generalInfo["offset"]!.toInt()!;
        hitStats[NoteJudgment.MISS] = 0;
        hitStats[NoteJudgment.GOOD] = 0;
        hitStats[NoteJudgment.GREAT] = 0;
        hitStats[NoteJudgment.PERFECT] = 0;
        hitStats[NoteJudgment.HOLD] = 0;
        hitStats[NoteJudgment.SLIP] = 0;
        super.init();
    }
    
    func addTimingPoint(timingPoint: TimingPoint) {
        timingPoints.append(timingPoint);
    }
    
    func addNote(note: Note) {
        notes.append(note);
        note.setTiming(timingPoints[note.timePoint], appearFor: msAppear[approach]);
        switch (note.noteColor) {
        case NoteColor.RED:
            note.texture = SKTexture(imageNamed: ("\(sector)SectorRedArc"));
            break;
        case NoteColor.GREEN:
            note.texture = SKTexture(imageNamed: ("\(sector)SectorGreenArc"));
            break;
        case NoteColor.BLUE:
            note.texture = SKTexture(imageNamed: ("\(sector)SectorBlueArc"));
            break;
        default:
            break;
        }
    }
    
    func addHold(hold: HoldNote) {
        addNote(hold);
    }
    
    func update(songTime timeSec: NSTimeInterval, cursorInHold: Bool) {
        let currTime = Int(timeSec*1000);
        prevSongTime = currTime;
        if (notes.count > 0) {
            let perfect = perfectRange[approach];
            let great = perfectRange[approach] + judgementDifference[approach];
            let good = perfectRange[approach] + judgementDifference[approach] * 2;
            let miss = perfectRange[approach] + judgementDifference[approach] * 3;
            var i: Int = 0;
            while (i < notes.count) {
                let nextNote = notes[i];
                if (nextNote.msAppear > currTime) {
                    return;
                }
                if (currTime - nextNote.msHit > miss) {
                    calcMiss();
                    nextNote.removeFromParent();
                    notes.removeAtIndex(i);
                    continue;
                }
                nextNote.alpha = 1;
                if let holdNote = notes[0] as? HoldNote {
                    if (holdNote.isHeld && currTime - lastHoldCycle > 100) {
                        lastHoldCycle = currTime;
                        if (cursorInHold) {
                            calcHold();
                        } else {
                            calcSlip();
                        }
                    }
                } else {
                    let timeDifference = currTime - nextNote.msAppear;
                    let scale = newScale(timeDifference);
                    nextNote.xScale = scale;
                    nextNote.yScale = scale;
                }
                i++;
            }
        }
    }
    
    func updateButton(button: ButtonColor, isPressed: Bool) {
        if (notes.count > 0) {
            let perfect = perfectRange[approach];
            let great = perfectRange[approach] + judgementDifference[approach];
            let good = perfectRange[approach] + judgementDifference[approach] * 2;
            let miss = perfectRange[approach] + judgementDifference[approach] * 3;
            if (!isPressed) {
                if let nextNote = notes[0] as? HoldNote {
                    nextNote.letGo();
                }
            } else {
                if let holdNote = notes[0] as? HoldNote {
                    if (prevSongTime - holdNote.msHit > 0) {
                        holdNote.holdDown();
                    }
                }
                var i: Int = 0;
                while (i < notes.count) {
                    let nextNote = notes[i];
                    if (nextNote.noteColor == button.rawValue) {
                        let timeDifference = prevSongTime - nextNote.msHit;
                        if (abs(timeDifference) > miss) {
                            return;
                        } else if (abs(timeDifference) > good) {
                            calcMiss();
                        } else if (abs(timeDifference) > great) {
                            calcGood();
                        } else if (abs(timeDifference) > perfect) {
                            calcGreat();
                        } else {
                            calcPerfect();
                        }
                        if let nextNote = notes[0] as? HoldNote {
                        } else {
                            nextNote.removeFromParent();
                            notes.removeAtIndex(i);
                            continue;
                        }
                    }
                    i++;
                }
            }
        }
    }
    
    private func calcMiss() {
        combo = 0;
        hitStats[NoteJudgment.MISS]! += 1;
        NSLog("Missed note");
    }
    
    private func calcGood() {
        combo = 0;
        hitStats[NoteJudgment.GOOD]! += 1;
        NSLog("Good note");
    }
    
    private func calcGreat() {
        combo++;
        hitStats[NoteJudgment.GREAT]! += 1;
        NSLog("Great note");
    }
    
    private func calcPerfect() {
        combo++;
        hitStats[NoteJudgment.PERFECT]! += 1;
        NSLog("Perfect note");
    }
    
    private func calcHold() {
        combo++;
        hitStats[NoteJudgment.HOLD]! += 1;
        NSLog("Hold note");
    }
    
    private func calcSlip() {
        combo = 0;
        hitStats[NoteJudgment.SLIP]! += 1;
        NSLog("Slip note");
    }
    
    private func newScale(timeDifference: Int) -> CGFloat {
        return CGFloat(lerp(lower: 0.1, upper: 1.0, val: Double(timeDifference)/Double(msAppear[approach])));
    }
    
    private func lerp(#lower: Double, upper: Double, val: Double) -> Double {
        return min(1, max(0, val)) * (upper-lower) + lower;
    }
}
