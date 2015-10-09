//
//  GreenButton.swift
//  RhythmDysc
//
//  Created by MUser on 6/2/15.
//  Copyright (c) 2015 TynyLabs. All rights reserved.
//

import UIKit;
import SpriteKit;

class GreenButton: Button {
    
    init() {
        super.init(texture: nil, color: UIColor.blackColor(), size: CGSize());
        upTexture = SKTexture(imageNamed: "GreenButtonUp");
        downTexture = SKTexture(imageNamed: "GreenButtonDown");
        texture = upTexture;
        self.name = "greenButton";
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
}
