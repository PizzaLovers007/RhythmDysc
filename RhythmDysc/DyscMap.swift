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
    let judgmentDifference: [Int] = [55, 50, 45, 40];
    let msAppear: [Int] = [1500, 1200, 900, 600];
    let soundPlayer: SoundPlayer = SoundPlayer();
    let judgmentTitle: SKLabelNode = SKLabelNode();
    let comboTitle: SKLabelNode = SKLabelNode();
    var timingPoints: [TimingPoint] = [TimingPoint]();
    var notes: [Note] = [Note]();
    var prevSongTime: Int = 0;
    var score: Int = 0;
    var combo: Int = 0;
    var hitStats: [NoteJudgment: Int] = [NoteJudgment: Int]();
    var lastHoldCycle: Int = 0;
    var currSector: Int = 0;
    var currTimingPointIndex: Int = 0;
    
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
        note.runAction(SKAction.rotateToAngle(CGFloat(M_PI*2/Double(sector)*Double(note.direction)), duration: 0));
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
        for node in hold.nodes {
            NSLog(node.description);
        }
    }
    
    func update(songTime timeSec: NSTimeInterval, cursorTheta: Double) {
        let currTime = Int(timeSec*1000);
        prevSongTime = currTime;
        let currTimingPoint: TimingPoint;
        if (currTimingPointIndex < timingPoints.count-1 && timingPoints[currTimingPointIndex+1].time <= currTime) {
            currTimingPoint = timingPoints[currTimingPointIndex+1];
        } else {
            currTimingPoint = timingPoints[currTimingPointIndex];
        }
        if (notes.count > 0) {
            let perfect = perfectRange[approach];
            let great = perfectRange[approach] + judgmentDifference[approach];
            let good = perfectRange[approach] + judgmentDifference[approach] * 2;
            let miss = perfectRange[approach] + judgmentDifference[approach] * 3;
            var i: Int = 0;
            while (i < notes.count) {
                let nextNote = notes[i];
                if (nextNote.msAppear > currTime) {
                    return;
                }
                nextNote.alpha = 1;
                if let holdNote = notes[0] as? HoldNote {
                    if (currTime - holdNote.msEnd > miss) {
                        lastHoldCycle = Int.max;
                        holdNote.removeFromParent();
                        notes.removeAtIndex(i);
                        continue;
                    } else if (!holdNote.hasHit && currTime - holdNote.msHit > miss) {
                        calcMiss();
                        holdNote.hasHit = true;
                    }
                    if (lastHoldCycle == Int.max) {
                        lastHoldCycle = holdNote.msHit;
                    }
                    let cursorInHold = holdNote.isInHold(angle: cursorTheta, time: currTime, sector: sector);
                    if (currTime > holdNote.msHit && currTime - lastHoldCycle > 200 && currTime < holdNote.msEnd) {
                        lastHoldCycle = currTime;
                        if (holdNote.isHeld) {
                            if (cursorInHold) {
                                calcHold();
                            } else {
                                calcSlip();
                            }
                        } else {
                            calcSlip();
                        }
                    }
                } else if (currTime - nextNote.msHit > miss) {
                    calcMiss();
                    nextNote.removeFromParent();
                    notes.removeAtIndex(i);
                    continue;
                }
                let timeDifference = currTime - nextNote.msAppear;
                let scale = newScale(timeDifference);
                nextNote.xScale = scale;
                nextNote.yScale = scale;
                i++;
            }
        }
    }
    
    func updateNotePositions(songTime timeSec: NSTimeInterval, dysc: SKSpriteNode) {
        let currTime = Int(timeSec*1000);
        for currNote in notes {
            let frac = currNote.getPositionFraction(currTime: currTime, appearTime: msAppear[approach]);
            let targetPositionX = Double(dysc.position.x) + Double(dysc.size.width)/2*cos(Double(currNote.direction)*M_PI*2/Double(sector));
            let targetPositionY = Double(dysc.position.y) + Double(dysc.size.height)/2*sin(Double(currNote.direction)*M_PI*2/Double(sector));
            let newPositionX = lerp(lower: Double(dysc.position.x), upper: targetPositionX, val: frac);
            let newPositionY = lerp(lower: Double(dysc.position.y), upper: targetPositionY, val: frac);
            currNote.runAction(SKAction.moveTo(CGPoint(x: newPositionX, y: newPositionY), duration: 0));
        }
    }
    
    func updateButton(button: ButtonColor, isPressed: Bool) {
        if (notes.count > 0) {
            let perfect = perfectRange[approach];
            let great = perfectRange[approach] + judgmentDifference[approach];
            let good = perfectRange[approach] + judgmentDifference[approach] * 2;
            let miss = perfectRange[approach] + judgmentDifference[approach] * 3;
            if (!isPressed) {
                if let nextNote = notes[0] as? HoldNote {
                    if (nextNote.noteColor == button.rawValue && currSector == nextNote.direction) {
                        nextNote.letGo();
                    }
                }
            } else {
                if let holdNote = notes[0] as? HoldNote {
                    if (holdNote.noteColor == button.rawValue && currSector == holdNote.direction) {
                        holdNote.holdDown();
                    }
                }
                var i: Int = 0;
                while (i < notes.count) {
                    let nextNote = notes[i];
                    if (nextNote.noteColor == button.rawValue && currSector == nextNote.direction) {
                        let timeDifference = prevSongTime - nextNote.msHit;
                        if (abs(timeDifference) > miss) {
                            return;
                        } else if (abs(timeDifference) > good) {
                            calcMiss();
                            judgmentTitle.text = "\(timeDifference)";
                        } else if (abs(timeDifference) > great) {
                            calcGood();
                            judgmentTitle.text = "\(timeDifference)";
                        } else if (abs(timeDifference) > perfect) {
                            calcGreat();
                            judgmentTitle.text = "\(timeDifference)";
                        } else {
                            calcPerfect();
                            judgmentTitle.text = "\(timeDifference)";
                        }
                        if let holdNote = notes[i] as? HoldNote {
                            holdNote.hasHit = true;
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
        comboTitle.text = "";
        judgmentTitle.text = "Miss";
        hitStats[NoteJudgment.MISS]! += 1;
        NSLog("Missed note");
        soundPlayer.playMiss();
    }
    
    private func calcGood() {
        combo = 0;
        comboTitle.text = "\(combo) COMBO!";
        judgmentTitle.text = "Good";
        hitStats[NoteJudgment.GOOD]! += 1;
        NSLog("Good note");
        soundPlayer.playGood();
    }
    
    private func calcGreat() {
        combo++;
        comboTitle.text = "\(combo) COMBO!";
        judgmentTitle.text = "Great";
        hitStats[NoteJudgment.GREAT]! += 1;
        NSLog("Great note");
        soundPlayer.playGreat();
    }
    
    private func calcPerfect() {
        combo++;
        comboTitle.text = "\(combo) COMBO!";
        judgmentTitle.text = "Perfect";
        hitStats[NoteJudgment.PERFECT]! += 1;
        NSLog("Perfect note");
        soundPlayer.playPerfect();
    }
    
    private func calcHold() {
        combo++;
        comboTitle.text = "\(combo) COMBO!";
        judgmentTitle.text = "Hold";
        hitStats[NoteJudgment.HOLD]! += 1;
        NSLog("Hold note");
        soundPlayer.playHold();
    }
    
    private func calcSlip() {
        combo = 0;
        comboTitle.text = "";
        judgmentTitle.text = "Slip";
        hitStats[NoteJudgment.SLIP]! += 1;
        NSLog("Slip note");
        soundPlayer.playSlip();
    }
    
    private func newScale(timeDifference: Int) -> CGFloat {
        return CGFloat(lerp(lower: 0.1, upper: 1.0, val: Double(timeDifference)/Double(msAppear[approach])));
    }
    
    private func lerp(#lower: Double, upper: Double, val: Double) -> Double {
        return min(1, max(0, val)) * (upper-lower) + lower;
    }
}
