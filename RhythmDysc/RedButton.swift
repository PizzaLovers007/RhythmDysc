//
//  RedButton.swift
//  RhythmDysc
//
//  Created by MUser on 6/2/15.
//  Copyright (c) 2015 TynyLabs. All rights reserved.
//

import UIKit;
import SpriteKit;

class RedButton: Button {
    
    init() {
        super.init(texture: nil, color: UIColor.blackColor(), size: CGSize());
        upTexture = SKTexture(imageNamed: "RedButtonUp");
        downTexture = SKTexture(imageNamed: "RedButtonDown");
        texture = upTexture;
        self.name = "redButton";
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
}
