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
    var timingPoints: [TimingPoint] = [TimingPoint]();
    var notes: [Note] = [Note]();
    
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
        super.init();
    }
    
    func addTimingPoint(timingPoint: TimingPoint) {
        timingPoints.append(timingPoint);
    }
    
    func addNote(note: Note) {
        notes.append(note);
        switch (note.color) {
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
        notes.append(hold);
        switch (hold.color) {
        case NoteColor.RED:
            hold.texture = SKTexture(imageNamed: ("\(sector)SectorRedArc"));
            break;
        case NoteColor.GREEN:
            hold.texture = SKTexture(imageNamed: ("\(sector)SectorGreenArc"));
            break;
        case NoteColor.BLUE:
            hold.texture = SKTexture(imageNamed: ("\(sector)SectorBlueArc"));
            break;
        default:
            break;
        }
    }
}
