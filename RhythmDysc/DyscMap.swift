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
    let preview: Int;
    let coverImage: UIImage;
    let perfectRange: [Int] = [100, 80, 60, 40];
    let judgmentDifference: [Int] = [45, 40, 35, 30];
    let msAppear: [Int] = [1800, 1500, 1200, 900];
    let soundPlayer: HitSoundPlayer = HitSoundPlayer();
    let judgmentTitle: SKLabelNode = SKLabelNode();
    let judgmentAction: SKAction;
    let comboTitle: SKLabelNode = SKLabelNode();
    var scene: SKScene!;
    var timingPoints: [TimingPoint] = [TimingPoint]();
    var notes: [Note] = [Note]();
    var prevSongTime: Int = 0;
    var score: Int = 0;
    var combo: Int = 0;
    var hitStats: [NoteJudgment: Int] = [NoteJudgment: Int]();
    var currSector: Int = 0;
    var currTimingPointIndex: Int = 0;
    var sparks: [NoteSpark] = [NoteSpark]();
    
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
        preview = 0;
        coverImage = UIImage(named: "")!;
        let zoomAction = SKAction.sequence([SKAction.scaleTo(1, duration: 0), SKAction.scaleTo(1.1, duration: 0.1), SKAction.scaleTo(1, duration: 0.1)]);
        let fadeAction = SKAction.sequence([SKAction.fadeAlphaTo(1, duration: 0), SKAction.waitForDuration(1), SKAction.fadeAlphaTo(0, duration: 1)]);
        judgmentAction = SKAction.group([zoomAction, fadeAction]);
        super.init();
    }
    
    init(generalInfo: [String: String]) {
        title = generalInfo["title"]!;
        artist = generalInfo["artist"]!;
        difficulty = generalInfo["difficulty"]!.toInt()!;
        approach = generalInfo["approach"]!.toInt()!;
        sector = generalInfo["sector"]!.toInt()!;
        preview = generalInfo["preview"]!.toInt()!;
        coverImage = UIImage(named: title)!;
        hitStats[NoteJudgment.MISS] = 0;
        hitStats[NoteJudgment.GOOD] = 0;
        hitStats[NoteJudgment.GREAT] = 0;
        hitStats[NoteJudgment.PERFECT] = 0;
        hitStats[NoteJudgment.HOLD] = 0;
        hitStats[NoteJudgment.SLIP] = 0;
        let zoomAction = SKAction.sequence([SKAction.scaleTo(1, duration: 0), SKAction.scaleTo(1.1, duration: 0.1), SKAction.scaleTo(1, duration: 0.1)]);
        let fadeAction = SKAction.sequence([SKAction.fadeAlphaTo(1, duration: 0), SKAction.waitForDuration(1), SKAction.fadeAlphaTo(0, duration: 1)]);
        judgmentAction = SKAction.group([zoomAction, fadeAction]);
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
        currTimingPoint.playMetronome(currTime, node: soundPlayer);
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
                } else if (!nextNote.hasAppeared) {
                    nextNote.hasAppeared = true;
                    nextNote.alpha = 1;
                }
                if let holdNote = notes[0] as? HoldNote {
                    if (currTime - holdNote.msEnd > miss) {
                        holdNote.removeFromParent();
                        notes.removeAtIndex(i);
                        continue;
                    } else if (!holdNote.hasHit && currTime - holdNote.msHit > miss) {
                        calcMiss(holdNote);
                        holdNote.hasHit = true;
                        holdNote.alpha = 0;
                    }
                    let cursorInHold = holdNote.isInHold(angle: cursorTheta, time: currTime, sector: sector);
                    if (currTime > holdNote.msHit && holdNote.msTicks.count > 0 && currTime > holdNote.msTicks[0]) {
                        if (holdNote.isHeld && cursorInHold) {
                            calcHold(holdNote);
                        } else {
                            calcSlip(holdNote);
                        }
                        holdNote.msTicks.removeAtIndex(0);
                    }
                } else if (currTime - nextNote.msHit > miss) {
                    calcMiss(nextNote);
                    nextNote.removeFromParent();
                    notes.removeAtIndex(i);
                    continue;
                }
                let timeDifference = currTime - nextNote.msAppear;
                let scale = newScale(timeDifference);
                if let holdNote = nextNote as? HoldNote {
                    if (holdNote.isHeld) {
                        nextNote.xScale = 1;
                        nextNote.yScale = 1;
                    } else {
                        nextNote.xScale = scale;
                        nextNote.yScale = scale;
                    }
                } else {
                    nextNote.xScale = scale;
                    nextNote.yScale = scale;
                }
                i++;
            }
        }
    }
    
    func updateNotePositions(songTime timeSec: NSTimeInterval, dysc: SKSpriteNode) {
        let currTime = Int(timeSec*1000);
        for currNote in notes {
            if (currNote.msAppear > currTime) {
                break;
            }
            let frac = currNote.getPositionFraction(currTime: currTime);
            let targetPositionX = Double(dysc.position.x) + Double(dysc.size.width)/2*cos(Double(currNote.direction)*M_PI*2/Double(sector));
            let targetPositionY = Double(dysc.position.y) + Double(dysc.size.height)/2*sin(Double(currNote.direction)*M_PI*2/Double(sector));
            let newPositionX = lerp(lower: Double(dysc.position.x), upper: targetPositionX, val: frac);
            let newPositionY = lerp(lower: Double(dysc.position.y), upper: targetPositionY, val: frac);
            if let holdNote = currNote as? HoldNote {
                holdNote.updateArea(currTime, sector: sector, dysc: dysc);
                if (holdNote.isHeld) {
                    currNote.runAction(SKAction.moveTo(CGPoint(x: targetPositionX, y: targetPositionY), duration: 0));
                } else {
                    currNote.runAction(SKAction.moveTo(CGPoint(x: newPositionX, y: newPositionY), duration: 0));
                }
            } else {
                currNote.runAction(SKAction.moveTo(CGPoint(x: newPositionX, y: newPositionY), duration: 0));
            }
            currNote.updateCurrTheta(time: currTime, sector: sector);
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
                    if (nextNote.noteColor == button.rawValue) {
                        nextNote.letGo();
                    }
                }
            } else {
                if let holdNote = notes[0] as? HoldNote {
                    if (holdNote.noteColor == button.rawValue && currSector == holdNote.direction) {
                        holdNote.holdDown();
                        holdNote.alpha = 0;
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
                            calcMiss(nextNote);
                            judgmentTitle.text = "\(timeDifference)";
                        } else if (abs(timeDifference) > great) {
                            calcGood(nextNote);
                            judgmentTitle.text = "\(timeDifference)";
                        } else if (abs(timeDifference) > perfect) {
                            calcGreat(nextNote);
                            judgmentTitle.text = "\(timeDifference)";
                        } else {
                            calcPerfect(nextNote);
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
    
    func updateSparks(theta: Double) {
        let tiltAcceleration = 300.0;
        let x = CGFloat(tiltAcceleration * cos(theta));
        let y = CGFloat(tiltAcceleration * sin(theta));
        var i: Int = 0;
        while (i < sparks.count) {
            let currSpark = sparks[i];
            if (currSpark.isDead) {
                sparks.removeAtIndex(i)
            } else {
                currSpark.particles.xAcceleration = x;
                currSpark.particles.yAcceleration = y;
                i++;
            }
        }
    }
    
    private func addSpark(note: Note, numSparks: Int) {
        let spark = NoteSpark(color: note.color, numSparks: numSparks, theta: note.currTheta);
        scene.addChild(spark);
        let dysc = (scene as! InGameScene).dysc;
        spark.position.x = dysc.position.x + dysc.size.width/2 * CGFloat(cos(note.currTheta));
        spark.position.y = dysc.position.y + dysc.size.height/2 * CGFloat(sin(note.currTheta));
        sparks.append(spark);
    }
    
    private func calcMiss(note: Note) {
        combo = 0;
        comboTitle.text = "";
        judgmentTitle.text = "Miss";
        judgmentTitle.removeActionForKey("ShowFade");
        judgmentTitle.runAction(judgmentAction, withKey: "ShowFade");
        hitStats[NoteJudgment.MISS]! += 1;
        NSLog("Missed note");
        soundPlayer.playMiss();
    }
    
    private func calcGood(note: Note) {
        combo = 0;
        comboTitle.text = "\(combo) COMBO!";
        judgmentTitle.text = "Good";
        judgmentTitle.removeActionForKey("ShowFade");
        judgmentTitle.runAction(judgmentAction, withKey: "ShowFade");
        hitStats[NoteJudgment.GOOD]! += 1;
        addSpark(note, numSparks: 10);
        NSLog("Good note");
        soundPlayer.playGood();
    }
    
    private func calcGreat(note: Note) {
        combo++;
        comboTitle.text = "\(combo) COMBO!";
        judgmentTitle.text = "Great";
        judgmentTitle.removeActionForKey("ShowFade");
        judgmentTitle.runAction(judgmentAction, withKey: "ShowFade");
        hitStats[NoteJudgment.GREAT]! += 1;
        addSpark(note, numSparks: 30);
        NSLog("Great note");
        soundPlayer.playGreat();
    }
    
    private func calcPerfect(note: Note) {
        combo++;
        comboTitle.text = "\(combo) COMBO!";
        judgmentTitle.text = "Perfect";
        judgmentTitle.removeActionForKey("ShowFade");
        judgmentTitle.runAction(judgmentAction, withKey: "ShowFade");
        hitStats[NoteJudgment.PERFECT]! += 1;
        addSpark(note, numSparks: 50);
        NSLog("Perfect note");
        soundPlayer.playPerfect();
    }
    
    private func calcHold(note: Note) {
        combo++;
        comboTitle.text = "\(combo) COMBO!";
        judgmentTitle.text = "Hold";
        judgmentTitle.removeActionForKey("ShowFade");
        judgmentTitle.runAction(judgmentAction, withKey: "ShowFade");
        hitStats[NoteJudgment.HOLD]! += 1;
        addSpark(note, numSparks: 5);
        NSLog("Hold note");
        soundPlayer.playHold();
    }
    
    private func calcSlip(note: Note) {
        if (combo > 10) {
            soundPlayer.playMiss();
        } else {
            soundPlayer.playSlip();
        }
        combo = 0;
        comboTitle.text = "";
        judgmentTitle.text = "Slip";
        judgmentTitle.removeActionForKey("ShowFade");
        judgmentTitle.runAction(judgmentAction, withKey: "ShowFade");
        hitStats[NoteJudgment.SLIP]! += 1;
        NSLog("Slip note");
    }
    
    private func newScale(timeDifference: Int) -> CGFloat {
        return CGFloat(Double(timeDifference)/Double(msAppear[approach]));
    }
    
    private func lerp(#lower: Double, upper: Double, val: Double) -> Double {
        return min(2, max(0, val)) * (upper-lower) + lower;
    }
}
