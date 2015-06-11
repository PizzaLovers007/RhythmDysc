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
    private(set) var nodes: [Node] = [Node]();
    
    override var description: String {
        return "Hold\(super.description) with \(nodes.count) Node(s)";
    }
    
    override init() {
        super.init();
    }
    
    init(direction dir: Int, color col: Int, timePoint tp: Int, measure meas: Int, beat bt: Double, rotation rot: Int, length len: Double) {
        super.init(direction: dir, color: col, timePoint: tp, measure: meas, beat: bt);
        addNode(rotation: rot, length: len);
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    func addNode(#rotation: Int, length: Double) {
        nodes.append(Node(rotation: rotation, length: length, ms: 0));
    }
    
    override func setTiming(timePoint: TimingPoint, appearFor appear: Int) {
        super.setTiming(timePoint, appearFor: appear);
        let msPerBeat = 60000/timePoint.bpm;
        var currLength = 0.0;
        for i in 0..<count(nodes) {
            nodes[i].ms = msHit + Int(round(currLength * msPerBeat));
            currLength += nodes[i].length;
        }
    }
    
    func letGo() {
        isHeld = false;
    }
    
    func holdDown() {
        isHeld = true;
    }
}
