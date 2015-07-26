//
//  NoteSpark.swift
//  RhythmDysc
//
//  Created by MUser on 7/23/15.
//  Copyright (c) 2015 TynyLabs. All rights reserved.
//

import UIKit;
import SpriteKit;

class NoteSpark: SKNode {
    
    let lifetime = 2.0;
    let particles = SKEmitterNode(fileNamed: "NoteSparks.sks");
    let maxSpread = 50.0;
    var isDead: Bool = false;
    
    init(color: UIColor, numSparks: Int, theta: Double) {
        super.init();
        particles.particleColor = color;
        particles.particleColorSequence = nil;
        particles.particleColorBlendFactor = 1.0;
        particles.numParticlesToEmit = numSparks;
        particles.emissionAngle = CGFloat(theta - M_PI);
        particles.particlePositionRange.dx = CGFloat(maxSpread * abs(sin(theta)));
        particles.particlePositionRange.dy = CGFloat(maxSpread * abs(cos(theta)));
        addChild(particles);
        delay(lifetime) {
            self.isDead = true;
            self.particles.hidden = true;
            self.removeFromParent();
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func delay(delay: Double, closure:() -> ()) {
        let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), closure);
    }
}