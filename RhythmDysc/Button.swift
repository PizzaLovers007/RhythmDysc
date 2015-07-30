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
    
    var upTexture: SKTexture! = SKTexture();
    var downTexture: SKTexture! = SKTexture();
    
    //TODO: add darkened images when pressed (or make a second pressed image)
    var isPressed: Bool = false;
    
    func pressButton() {
        isPressed = true;
        colorBlendFactor = 0.25;
    }
    
    func releaseButton() {
        isPressed = false;
        colorBlendFactor = 0;
    }
}
