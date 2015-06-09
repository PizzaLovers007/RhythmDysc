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
        var description: String {
            return "Rotating \(rotation) for \(length)";
        }
    }
    
    private(set) var nodes: [Node] = [Node]();
    
    override var description: String {
        return "Hold\(super.description) with \(nodes.count) Node(s)";
    }
    
    override init() {
        super.init();
    }
    
    init(direction dir: Int, color col: Int, measure meas: Int, beat bt: Double, rotation rot: Int, length len: Double) {
        super.init(direction: dir, color: col, measure: meas, beat: bt);
        addNode(rotation: rot, length: len);
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    func addNode(#rotation: Int, length: Double) {
        nodes.append(Node(rotation: rotation, length: length));
    }
}
