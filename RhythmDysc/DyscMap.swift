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
    let scoreMultiplier: Double;
    let coverImage: UIImage;
    let perfectRange: [Int] = [100, 80, 60, 40];
    let judgmentDifference: [Int] = [45, 40, 35, 30];
    let msAppear: [Int] = [1700, 1500, 1300, 1100];
    let soundPlayer: HitSoundPlayer = HitSoundPlayer();
    let judgmentLabel = SKLabelNode();
    let judgmentAction: SKAction;
    let comboLabel = SKLabelNode();
    let scoreLabel = SKLabelNode();
    let hitErrorLabel = SKLabelNode();
    let accuracyLabel = SKLabelNode();
    weak var scene: InGameScene!;
    var timingPoints: [TimingPoint] = [TimingPoint]();
    var notes: [Note] = [Note]();
    var prevSongTime: Int = 0;
    var score: Int = 0;
    var combo: Int = 0;
    var maxCombo: Int = 0;
    var accuracy: Double = 0;
    var notesPassed: Int = 0;
    var totalBaseScore: Int = 0;
    var hitStats: [NoteJudgment: Int] = [NoteJudgment: Int]();
    var currSector: Int = 0;
    var currTimingPointIndex: Int = 0;
    var sparks: [NoteSpark] = [NoteSpark]();
    var heldButtons: [Bool] = [false, false, false];
    
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
        scoreMultiplier = 0;
        coverImage = UIImage(named: "")!;
        let zoomAction = SKAction.sequence([SKAction.scaleTo(1, duration: 0), SKAction.scaleTo(1.1, duration: 0.1), SKAction.scaleTo(1, duration: 0.1)]);
        let fadeAction = SKAction.sequence([SKAction.fadeAlphaTo(1, duration: 0), SKAction.waitForDuration(1), SKAction.fadeAlphaTo(0, duration: 1)]);
        judgmentAction = SKAction.group([zoomAction, fadeAction]);
        super.init();
    }
    
    init(generalInfo: [String: String]) {
        title = generalInfo["title"]!;
        artist = generalInfo["artist"]!;
        difficulty = Int(generalInfo["difficulty"]!)!;
        approach = Int(generalInfo["approach"]!)!;
        sector = Int(generalInfo["sector"]!)!;
        preview = Int(generalInfo["preview"]!)!;
        scoreMultiplier = Double(approach+2)/2 * log2(Double(sector))/2 / 32;     //difficultyMultiplier * sectorMultiplier / offsetMultiplier
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
        scoreLabel.text = String(format: "%08d", 0);
        accuracyLabel.text = String(format: "%.2f%%", 0);
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right;
        scoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top;
        accuracyLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left;
        accuracyLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top;
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
//            let perfect = perfectRange[approach];
//            let great = perfectRange[approach] + judgmentDifference[approach];
//            let good = perfectRange[approach] + judgmentDifference[approach] * 2;
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
                    if (currTime >= holdNote.msHit && holdNote.msTicks.count > 0 && currTime >= holdNote.msTicks[0]) {
                        if ((holdNote.isBeingHeld() || heldButtons[holdNote.noteColor]) && cursorInHold) {
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
                    if (holdNote.isBeingHeld()) {
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
                if (holdNote.isBeingHeld()) {
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
    
    func updateButton(button: ButtonColor, isPressed: Bool, songTime timeSec: NSTimeInterval) {
        let currTime = Int(timeSec*1000);
        heldButtons[button.rawValue] = isPressed;
        if (notes.count > 0) {
            let perfect = perfectRange[approach];
            let great = perfectRange[approach] + judgmentDifference[approach];
            let good = perfectRange[approach] + judgmentDifference[approach] * 2;
            let miss = perfectRange[approach] + judgmentDifference[approach] * 3;
            if (!isPressed) {
                if let holdNote = notes[0] as? HoldNote {
                    if (holdNote.noteColor == button.rawValue && holdNote.isBeingHeld()) {
                        holdNote.letGo(currTime);
                    }
                }
            } else {
                if let holdNote = notes[0] as? HoldNote {
                    let timeDifference = currTime - holdNote.msHit;
                    if (holdNote.noteColor == button.rawValue && (currSector == holdNote.direction || holdNote.hasHit) && abs(timeDifference) <= miss) {
                        holdNote.holdDown();
                        holdNote.alpha = 0;
                    }
                }
                let nextNote = notes[0];
                if (nextNote.noteColor == button.rawValue && currSector == nextNote.direction) {
                    let timeDifference = currTime - nextNote.msHit;
                    if (abs(timeDifference) > miss) {
                        return;
                    } else if (abs(timeDifference) > good) {
                        calcMiss(nextNote);
                        hitErrorLabel.text = "\(timeDifference)";
                    } else if (abs(timeDifference) > great) {
                        calcGood(nextNote);
                        hitErrorLabel.text = "\(timeDifference)";
                    } else if (abs(timeDifference) > perfect) {
                        calcGreat(nextNote);
                        hitErrorLabel.text = "\(timeDifference)";
                    } else {
                        calcPerfect(nextNote);
                        hitErrorLabel.text = "\(timeDifference)";
                    }
                    if let holdNote = notes[0] as? HoldNote {
                        holdNote.hasHit = true;
                    } else {
                        nextNote.removeFromParent();
                        notes.removeAtIndex(0);
                    }
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
        let spark = NoteSpark(color: note.color, numSparks: numSparks, theta: scene.cursor.theta);
        scene.addChild(spark);
        spark.position = scene.cursor.position;
        sparks.append(spark);
    }
    
    private func calcAccuracy(basePoints basePoints: Int) {
        notesPassed++;
        totalBaseScore += basePoints;
        accuracy = Double(totalBaseScore) / Double(notesPassed);
        accuracyLabel.text = String(format: "%.2f%%", accuracy);
    }
    
    private func calcMiss(note: Note) {
        if (combo > 10) {
            soundPlayer.playMiss();
        }
        combo = 0;
        scoreLabel.text = String(format: "%08d", score);
        comboLabel.text = "";
        judgmentLabel.text = "Miss";
        judgmentLabel.removeActionForKey("ShowFade");
        judgmentLabel.runAction(judgmentAction, withKey: "ShowFade");
        hitStats[NoteJudgment.MISS]! += 1;
        NSLog("Missed note");
        calcAccuracy(basePoints: 0);
    }
    
    private func calcGood(note: Note) {
        combo++;
        if (combo > maxCombo) {
            maxCombo = combo;
        }
        score += 20;
        score += Int(round(20 * Double(combo) * scoreMultiplier));
        scoreLabel.text = String(format: "%08d", score);
        comboLabel.text = "\(combo) COMBO!";
        judgmentLabel.text = "Good";
        judgmentLabel.removeActionForKey("ShowFade");
        judgmentLabel.runAction(judgmentAction, withKey: "ShowFade");
        hitStats[NoteJudgment.GOOD]! += 1;
        addSpark(note, numSparks: 10);
        NSLog("Good note");
        soundPlayer.playGood();
        calcAccuracy(basePoints: 20);
    }
    
    private func calcGreat(note: Note) {
        combo++;
        if (combo > maxCombo) {
            maxCombo = combo;
        }
        score += 50;
        score += Int(round(50 * Double(combo) * scoreMultiplier));
        scoreLabel.text = String(format: "%08d", score);
        comboLabel.text = "\(combo) COMBO!";
        judgmentLabel.text = "Great!";
        judgmentLabel.removeActionForKey("ShowFade");
        judgmentLabel.runAction(judgmentAction, withKey: "ShowFade");
        hitStats[NoteJudgment.GREAT]! += 1;
        addSpark(note, numSparks: 30);
        NSLog("Great note");
        soundPlayer.playGreat();
        calcAccuracy(basePoints: 50);
    }
    
    private func calcPerfect(note: Note) {
        combo++;
        if (combo > maxCombo) {
            maxCombo = combo;
        }
        score += 100;
        score += Int(round(100 * Double(combo) * scoreMultiplier));
        scoreLabel.text = String(format: "%08d", score);
        comboLabel.text = "\(combo) COMBO!";
        judgmentLabel.text = "Perfect!";
        judgmentLabel.removeActionForKey("ShowFade");
        judgmentLabel.runAction(judgmentAction, withKey: "ShowFade");
        hitStats[NoteJudgment.PERFECT]! += 1;
        addSpark(note, numSparks: 50);
        NSLog("Perfect note");
        soundPlayer.playPerfect();
        calcAccuracy(basePoints: 100);
    }
    
    private func calcHold(note: Note) {
        combo++;
        if (combo > maxCombo) {
            maxCombo = combo;
        }
        score += 10;
        score += Int(round(10 * Double(combo) * scoreMultiplier));
        scoreLabel.text = String(format: "%08d", score);
        comboLabel.text = "\(combo) COMBO!";
        judgmentLabel.text = "Hold";
        judgmentLabel.removeActionForKey("ShowFade");
        judgmentLabel.runAction(judgmentAction, withKey: "ShowFade");
        hitStats[NoteJudgment.HOLD]! += 1;
        addSpark(note, numSparks: 8);
        NSLog("Hold note");
        soundPlayer.playHold();
        calcAccuracy(basePoints: 100);
    }
    
    private func calcSlip(note: Note) {
        if (combo > 10) {
            soundPlayer.playMiss();
        } else {
            soundPlayer.playSlip();
        }
        scoreLabel.text = String(format: "%08d", score);
        combo = 0;
        comboLabel.text = "";
        judgmentLabel.text = "Slip";
        judgmentLabel.removeActionForKey("ShowFade");
        judgmentLabel.runAction(judgmentAction, withKey: "ShowFade");
        hitStats[NoteJudgment.SLIP]! += 1;
        NSLog("Slip note");
        calcAccuracy(basePoints: 0);
    }
    
    private func newScale(timeDifference: Int) -> CGFloat {
        return CGFloat(Double(timeDifference)/Double(msAppear[approach]));
    }
    
    private func lerp(lower lower: Double, upper: Double, val: Double) -> Double {
        return min(2, max(0, val)) * (upper-lower) + lower;
    }
}
