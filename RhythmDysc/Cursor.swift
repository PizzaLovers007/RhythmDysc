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
        let texture = SKTexture(imageNamed: "Cursor2");
        super.init(texture: texture, color: UIColor.whiteColor(), size: texture.size());
    }

    required init?(coder aDecoder: NSCoder) {
        center = CGPoint(x: 0, y: 0);
        super.init(coder: aDecoder);
    }
    
    func startUpdates() {
        motionManager.deviceMotionUpdateInterval = 0.005;
        motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler: { data, error in
            self.theta = atan2(-data.attitude.pitch/M_PI, data.attitude.roll/M_PI);
            self.position.x = self.center.x + CGFloat(self.radius * cos(self.theta));
            self.position.y = self.center.y + CGFloat(self.radius * sin(self.theta));
        });
    }
}
