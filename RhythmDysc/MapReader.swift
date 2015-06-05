//
//  MapReader.swift
//  RhythmDysc
//
//  Created by MUser on 6/3/15.
//  Copyright (c) 2015 TynyLabs. All rights reserved.
//

import UIKit

class MapReader: NSObject {
    
    class func readFile(mapURL: NSURL) -> DyscMap {
        let fileManager = NSFileManager.defaultManager();
        
        let fileContent = String(contentsOfURL: mapURL, encoding: NSUTF8StringEncoding, error: nil);
        if (fileContent != nil) {
            NSLog(fileContent!);
        }
        let mapData: DyscMap = DyscMap();
        
        return mapData;
    }
}
