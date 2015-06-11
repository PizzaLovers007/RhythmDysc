//
//  HoldNote.swift
//  RhythmDysc
//
//  Created by MUser on 6/8/15.
//  Copyright (c) 2015 TynyLabs. All rights reserved.
//

import UIKit;
import SpriteKit;

class HoldNote: Note {
    
    struct Node {
        let rotation: Int;
        let length: Double;
        var ms: Int = 0;
        var description: String {
            return "Rotating \(rotation) for \(length)";
        }
    }
    
    var isHeld: Bool = false;
    var hasHit: Bool = false;
    var msEnd: Int = 0;
    private(set) var nodes: [Node] = [Node]();
    
    override var description: String {
        return "Hold\(super.description) with \(nodes.count) Node(s)";
    }
    
    override init() {
        super.init();
    }
    
    init(direction dir: Int, color col: Int, timePoint tp: Int, measure meas: Int, beat bt: Double, rotation rot: Int, length len: Double) {
        super.init(direction: dir, color: col, timePoint: tp, measure: meas, beat: bt);
        nodes.append(Node(rotation: 0, length: 0, ms: 0));
        addNode(rotation: rot, length: len);
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    func addNode(#rotation: Int, length: Double) {
        nodes.insert(Node(rotation: rotation, length: length, ms: 0), atIndex: nodes.count-1);
    }
    
    override func setTiming(timePoint: TimingPoint, appearFor appear: Int) {
        super.setTiming(timePoint, appearFor: appear);
        let msPerBeat = 60000/timePoint.bpm;
        var currLength = 0.0;
        for i in 0..<count(nodes) {
            nodes[i].ms = msHit + Int(round(currLength * msPerBeat));
            currLength += nodes[i].length;
        }
        msEnd = msHit + Int(round(currLength * msPerBeat));
    }
    
    func letGo() {
        isHeld = false;
    }
    
    func holdDown() {
        isHeld = true;
    }
    
    func isInHold(#angle: Double, time: Int, sector: Int) -> Bool {
        let cursorAngle = (angle + M_PI*2) % (M_PI*2);
        for i in stride(from: nodes.count-2, through: 0, by: -1) {
            if (nodes[i].ms < time) {
                var currDirection = direction;
                for e in 0..<i {
                    currDirection = (currDirection + nodes[e].rotation) % sector;
                }
                let timeFraction = Double(time - nodes[i].ms) / Double(nodes[i+1].ms - nodes[i].ms);
                let firstAngle = Double(currDirection)*M_PI*2/Double(sector);
                currDirection = (currDirection + nodes[i].rotation) % sector;
                let secondAngle = Double(currDirection)*M_PI*2/Double(sector);
                let noteAngle = lerp(lower: firstAngle, upper: secondAngle, val: timeFraction);
                NSLog("\(noteAngle)");
                let angleDifference = min(abs(cursorAngle - noteAngle), min(abs(cursorAngle - noteAngle + M_PI*2), abs(cursorAngle - noteAngle - M_PI*2)));
                return angleDifference < M_PI/Double(sector);
            }
        }
        return false;
    }
    
    private func lerp(#lower: Double, upper: Double, val: Double) -> Double {
        return min(1, max(0, val)) * (upper-lower) + lower;
    }
}
