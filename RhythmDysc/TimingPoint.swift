//
//  TimingPoint.swift
//  RhythmDysc
//
//  Created by MUser on 6/8/15.
//  Copyright (c) 2015 TynyLabs. All rights reserved.
//

import UIKit;

class TimingPoint: NSObject {
    let time: Int;
    let bpm: Double;
    let keySignature: Int;
    
    init(time: Int, bpm: Double, keySignature: Int) {
        self.time = time;
        self.bpm = bpm;
        self.keySignature = keySignature;
        super.init();
    }
}
