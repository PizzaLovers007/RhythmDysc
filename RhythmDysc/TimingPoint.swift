//
//  TimingPoint.swift
//  RhythmDysc
//
//  Created by MUser on 6/8/15.
//  Copyright (c) 2015 TynyLabs. All rights reserved.
//

import UIKit;
import SpriteKit;

class TimingPoint: NSObject {
    let time: Int;
    let bpm: Double;
    let keySignature: Int;
    let msPerBeat: Double;
    let useMetronome = false;
    var nextMetronomeTick: Double;
    var currMetronomeBeat: Int;
    
    init(time t: Int, bpm beat: Double, keySignature ks: Int) {
        time = t;
        bpm = beat;
        keySignature = ks;
        msPerBeat = 60000/bpm;
        nextMetronomeTick = Double(time);
        currMetronomeBeat = 0;
        super.init();
    }
    
    func playMetronome(currTime: Int, node: SKNode) {
        if (useMetronome && currTime > Int(round(nextMetronomeTick))) {
            if (currMetronomeBeat == 0) {
                node.runAction(SKAction.playSoundFileNamed("metronomeTick.wav", waitForCompletion: false));
            } else {
                node.runAction(SKAction.playSoundFileNamed("metronomeTock.wav", waitForCompletion: false));
            }
            currMetronomeBeat++;
            currMetronomeBeat %= keySignature;
            nextMetronomeTick += msPerBeat;
        }
    }
}
