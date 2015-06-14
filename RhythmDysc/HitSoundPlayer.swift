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
   
    override init() {
        super.init();
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func playMiss() {
        self.runAction(SKAction.playSoundFileNamed("soundMiss.mp3", waitForCompletion: false));
    }
    
    func playGood() {
        self.runAction(SKAction.playSoundFileNamed("soundGood.wav", waitForCompletion: false));
    }
    
    func playGreat() {
        self.runAction(SKAction.playSoundFileNamed("soundGreat.wav", waitForCompletion: false));
    }
    
    func playPerfect() {
        self.runAction(SKAction.playSoundFileNamed("soundPerfect.wav", waitForCompletion: false));
    }
    
    func playHold() {
        self.runAction(SKAction.playSoundFileNamed("soundHold.wav", waitForCompletion: false));
    }
    
    func playSlip() {
        self.runAction(SKAction.playSoundFileNamed("soundSlip.wav", waitForCompletion: false));
    }
}
