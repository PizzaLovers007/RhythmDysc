//
//  SongSelection.swift
//  RhythmDysc
//
//  Created by MUser on 6/17/15.
//  Copyright (c) 2015 TynyLabs. All rights reserved.
//

import UIKit;
import SpriteKit;

class SongSelection: SKSpriteNode {
    
    override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
        
        super.init(texture: texture, color: color, size: size);
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
}
