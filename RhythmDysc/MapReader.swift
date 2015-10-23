//
//  MapReader.swift
//  RhythmDysc
//
//  Created by MUser on 6/3/15.
//  Copyright (c) 2015 TynyLabs. All rights reserved.
//

import UIKit;

class MapReader: NSObject {
    
    class func readFile(mapURL: NSURL) -> DyscMap {
//        let fileManager = NSFileManager.defaultManager();
        
        do {
            let fileContent = try String(contentsOfURL: mapURL, encoding: NSUTF8StringEncoding);
            let scanner: NSScanner = NSScanner(string: fileContent);
            let parseCharacterSet = NSMutableCharacterSet.newlineCharacterSet();
            parseCharacterSet.formUnionWithCharacterSet(NSCharacterSet(charactersInString: "=,"));
            scanner.charactersToBeSkipped = parseCharacterSet;
            var next: NSString? = nil;
            
            //General section
            scanner.scanUpToString("\n", intoString: nil);
            scanner.scanUpToString("\n\n", intoString: &next);
            let generalScanner: NSScanner = NSScanner(string: next as! String);
            generalScanner.charactersToBeSkipped = parseCharacterSet;
            var generalInfo = [String: String]();
            while (generalScanner.scanUpToString("=", intoString: &next)) {
                let key: String = next as! String;
                generalScanner.scanUpToString("\n", intoString: &next);
                generalInfo[key] = next as? String;
            }
            let mapData: DyscMap = DyscMap(generalInfo: generalInfo);
            
            //Timing section
            scanner.scanUpToString("\n", intoString: nil);
            scanner.scanUpToString("\n\n", intoString: &next);
            let timingScanner: NSScanner = NSScanner(string: next as! String);
            timingScanner.charactersToBeSkipped = parseCharacterSet;
            while (timingScanner.scanUpToString("\n", intoString: &next)) {
                var line = next!.componentsSeparatedByString(",");
                let time: Int = Int(line[0])!;
                let bpm: Double = (line[1] as NSString).doubleValue;
                let keySignature: Int = Int(line[2])!;
                let timingPoint: TimingPoint = TimingPoint(time: time, bpm: bpm, keySignature: keySignature);
                mapData.addTimingPoint(timingPoint);
            }
            
            //Notes section
            scanner.scanUpToString("\n", intoString: nil);
            let notesScanner: NSScanner = NSScanner(string: scanner.string.substringFromIndex(scanner.string.startIndex));
            notesScanner.charactersToBeSkipped = parseCharacterSet;
            var currHoldNote: HoldNote?;
            while (scanner.scanUpToString("\n", intoString: &next)) {
                var line = next!.componentsSeparatedByString(",");
                let type: Int = Int(line[0])!;
                switch (type) {
                case 0:     //Regular note
                    if (currHoldNote != nil) {
                        mapData.addHold(currHoldNote!);
                        currHoldNote = nil;
                    }
                    let direction: Int = Int(line[1])!;
                    let color: Int = Int(line[2])!;
                    let timePoint: Int = Int(line[3])!;
                    let measure: Int = Int(line[4])!;
                    let beat: Double = (line[5] as NSString).doubleValue;
                    mapData.addNote(Note(direction: direction, color: color, timePoint: timePoint, measure: measure, beat: beat));
                    break;
                case 1:     //Hold note
                    if (currHoldNote != nil) {
                        mapData.addHold(currHoldNote!);
                        currHoldNote = nil;
                    }
                    let direction: Int = Int(line[1])!;
                    let color: Int = Int(line[2])!;
                    let timePoint: Int = Int(line[3])!;
                    let measure: Int = Int(line[4])!;
                    let beat: Double = (line[5] as NSString).doubleValue;
                    let rotation: Int = Int(line[6])!;
                    let length: Double = (line[7] as NSString).doubleValue;
                    currHoldNote = HoldNote(direction: direction, color: color, timePoint: timePoint, measure: measure, beat: beat, rotation: rotation, length: length);
                    break;
                case 2:     //Hold note node
                    let rotation = Int(line[1])!;
                    let length: Double = (line[2] as NSString).doubleValue;
                    if (currHoldNote == nil) {
                        NSLog("Hold note node without starting hold note!");
                        break;
                    }
                    currHoldNote!.addNode(rotation: rotation, length: length);
                    break;
                default:
                    break;
                }
            }
            if (currHoldNote != nil) {
                mapData.addHold(currHoldNote!);
                currHoldNote = nil;
            }
            
            return mapData;
            
        } catch {
            print(error);
        }
        return DyscMap();
    }
}
