//
//  Button.swift
//  RhythmDysc
//
//  Created by MUser on 6/3/15.
//  Copyright (c) 2015 TynyLabs. All rights reserved.
//

import UIKit;
import SpriteKit;

enum ButtonColor: Int {
    case RED = 2;
    case GREEN = 1;
    case BLUE = 0;
}

class Button: SKSpriteNode {
    
    //TODO: add darkened images when pressed (or make a second pressed image)
    var isPressed: Bool = false;
    
    func pressButton() {
        isPressed = true;
    }
    
    func releaseButton() {
        isPressed = false;
    }
}
