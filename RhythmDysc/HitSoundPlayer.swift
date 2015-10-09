//
//  SoundPlayer.swift
//  RhythmDysc
//
//  Created by MUser on 6/11/15.
//  Copyright (c) 2015 TynyLabs. All rights reserved.
//

import UIKit;
import SpriteKit;

class HitSoundPlayer: SKNode {
    
    let missAction = SKAction.playSoundFileNamed("soundMiss.mp3", waitForCompletion: false);
    let goodAction = SKAction.playSoundFileNamed("soundGood.wav", waitForCompletion: false);
    let greatAction = SKAction.playSoundFileNamed("soundGreat.wav", waitForCompletion: false);
    let perfectAction = SKAction.playSoundFileNamed("soundPerfect.wav", waitForCompletion: false);
    let holdAction = SKAction.playSoundFileNamed("soundHold.wav", waitForCompletion: false);
    let slipAction = SKAction.playSoundFileNamed("soundSlip.wav", waitForCompletion: false);
    
    override init() {
        super.init();
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func playMiss() {
        self.runAction(missAction);
    }
    
    func playGood() {
        self.runAction(goodAction);
    }
    
    func playGreat() {
        self.runAction(greatAction);
    }
    
    func playPerfect() {
        self.runAction(perfectAction);
    }
    
    func playHold() {
        self.runAction(holdAction);
    }
    
    func playSlip() {
        self.runAction(slipAction);
    }
}
