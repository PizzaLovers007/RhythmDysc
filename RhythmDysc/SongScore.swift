//
//  SongScore.swift
//  RhythmDysc
//
//  Created by MUser on 8/1/15.
//  Copyright (c) 2015 TynyLabs. All rights reserved.
//

import UIKit;
import CoreData;

class SongScore: NSManagedObject {
    
    @NSManaged var songTitle: String;
    @NSManaged var sectors: NSNumber;
    @NSManaged var difficulty: NSNumber;
    @NSManaged var grade: String;
    @NSManaged var score: NSNumber;
    @NSManaged var accuracy: NSNumber;
    @NSManaged var maxCombo: NSNumber;
}
