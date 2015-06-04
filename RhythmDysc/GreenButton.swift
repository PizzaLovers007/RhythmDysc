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
        let texture = SKTexture(imageNamed: "GreenButton");
        super.init(texture: texture, color: UIColor.whiteColor(), size: texture.size());
        self.name = "greenButton";
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
}
