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
    var radius: Double = 1;
    var center: CGPoint = CGPoint(x: 0, y: 0);
    var theta: Double = 0;
    
    init() {
        center = CGPoint(x: 0, y: 0);
        let cursorTexture = SKTexture(imageNamed: "Cursor2");
        let tiltTexture = SKTexture(imageNamed: "Cursor");
        super.init(texture: cursorTexture, color: UIColor.whiteColor(), size: cursorTexture.size());
    }

    required init?(coder aDecoder: NSCoder) {
        center = CGPoint(x: 0, y: 0);
        let tiltTexture = SKTexture(imageNamed: "Cursor");
        super.init(coder: aDecoder);
    }
    
    func startUpdates() {
        motionManager.deviceMotionUpdateInterval = 0.02;
        motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler: { data, error in
            let pitch = data.attitude.pitch;
            let roll = data.attitude.roll;
            self.theta = atan2(-pitch/M_PI, roll/M_PI);
            self.position.x = self.center.x + CGFloat(self.radius * cos(self.theta));
            self.position.y = self.center.y + CGFloat(self.radius * sin(self.theta));
        });
    }
    
    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates();
    }
}
