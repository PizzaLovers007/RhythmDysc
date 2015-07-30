//
//  BlueButton.swift
//  RhythmDysc
//
//  Created by MUser on 6/2/15.
//  Copyright (c) 2015 TynyLabs. All rights reserved.
//

import UIKit;
import SpriteKit;

class BlueButton: Button {
    
    init() {
        super.init(texture: nil, color: UIColor.blackColor(), size: CGSize());
        upTexture = SKTexture(imageNamed: "BlueButtonUp");
        downTexture = SKTexture(imageNamed: "BlueButtonDown");
        texture = upTexture;
        self.name = "blueButton";
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
}
