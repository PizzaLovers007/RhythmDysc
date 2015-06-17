//
//  Cursor.swift
//  RhythmDysc
//
//  Created by MUser on 6/9/15.
//  Copyright (c) 2015 TynyLabs. All rights reserved.
//

import UIKit;
import SpriteKit;
import CoreMotion;

class Cursor: SKSpriteNode {
    
    let motionManager: CMMotionManager = CMMotionManager();
    let maxTiltCalculations: Double = 50;
    let tiltSprite: SKSpriteNode;
    var radius: Double = 1;
    var center: CGPoint = CGPoint(x: 0, y: 0);
    var theta: Double = 0;
    var pitchOffset: Double = 0;
    var rollOffset: Double = 0;
    var tiltCalculations: Double = 0;
    
    init() {
        center = CGPoint(x: 0, y: 0);
        let cursorTexture = SKTexture(imageNamed: "Cursor2");
        let tiltTexture = SKTexture(imageNamed: "Cursor");
        tiltSprite = SKSpriteNode(texture: tiltTexture, size: tiltTexture.size());
        super.init(texture: cursorTexture, color: UIColor.whiteColor(), size: cursorTexture.size());
    }

    required init?(coder aDecoder: NSCoder) {
        center = CGPoint(x: 0, y: 0);
        let tiltTexture = SKTexture(imageNamed: "Cursor");
        tiltSprite = SKSpriteNode(texture: tiltTexture, size: tiltTexture.size());
        super.init(coder: aDecoder);
    }
    
    func startUpdates() {
        motionManager.deviceMotionUpdateInterval = 0.02;
        motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler: { data, error in
            let pitch = data.attitude.pitch - self.pitchOffset;
            let roll = data.attitude.roll - self.rollOffset;
            let tiltRadius = sqrt(sqrt(pow(pitch/M_PI, 2) + pow(roll/M_PI, 2)) * 600) * 4;
            self.theta = atan2(-pitch/M_PI, roll/M_PI);
            self.position.x = self.center.x + CGFloat(self.radius * cos(self.theta));
            self.position.y = self.center.y + CGFloat(self.radius * sin(self.theta));
            self.tiltSprite.position.x = self.center.x + CGFloat(tiltRadius * cos(self.theta));
            self.tiltSprite.position.y = self.center.y + CGFloat(tiltRadius * sin(self.theta));
            if (self.tiltCalculations < self.maxTiltCalculations) {
                self.tiltCalculations++;
                self.pitchOffset = (self.pitchOffset * (self.tiltCalculations-1) + data.attitude.pitch) / self.tiltCalculations;
                self.rollOffset = (self.rollOffset * (self.tiltCalculations-1) + data.attitude.roll) / self.tiltCalculations;
            }
        });
    }
}
