//
//  HoldNote.swift
//  RhythmDysc
//
//  Created by MUser on 6/8/15.
//  Copyright (c) 2015 TynyLabs. All rights reserved.
//

import UIKit;
import SpriteKit;

class HoldNote: Note {
    
    struct Node {
        let rotation: Int;
        let length: Double;
        var ms: Int = 0;
        var description: String {
            return "Rotating \(rotation) for \(length)";
        }
    }
    
    let pathNode: SKShapeNode = SKShapeNode();
    var path: CGMutablePath = CGPathCreateMutable();
    var isHeld: Bool = false;
    var hasHit: Bool = false;
    var msEnd: Int = 0;
    var msTicks: [Int] = [Int]();
    private(set) var nodes: [Node] = [Node]();
    
    override var description: String {
        return "Hold\(super.description) with \(nodes.count) Node(s)";
    }
    
    override init() {
        super.init();
    }
    
    init(direction dir: Int, color col: Int, timePoint tp: Int, measure meas: Int, beat bt: Double, rotation rot: Int, length len: Double) {
        super.init(direction: dir, color: col, timePoint: tp, measure: meas, beat: bt);
        nodes.append(Node(rotation: 0, length: 0, ms: 0));
        addNode(rotation: rot, length: len);
        switch (noteColor) {
        case NoteColor.RED:
            pathNode.strokeColor = UIColor.redColor();
            pathNode.fillColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.3);
            break;
        case NoteColor.GREEN:
            pathNode.strokeColor = UIColor.greenColor();
            pathNode.fillColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.3);
            break;
        case NoteColor.BLUE:
            pathNode.strokeColor = UIColor.blueColor();
            pathNode.fillColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.3);
            break;
        default:
            pathNode.strokeColor = UIColor.whiteColor();
            break;
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    func addNode(#rotation: Int, length: Double) {
        nodes.insert(Node(rotation: rotation, length: length, ms: 0), atIndex: nodes.count-1);
    }
    
    func letGo() {
        isHeld = false;
    }
    
    func holdDown() {
        isHeld = true;
    }
    
    func isInHold(#angle: Double, time: Int, sector: Int) -> Bool {
        let TAU = M_PI*2;
        let cursorAngle = (angle + TAU) % (TAU);
        let noteAngle = (getCurrentNoteAngle(time: time, sector: sector) % (TAU) + TAU) % (TAU);
        let lowerAngleDifference = abs(cursorAngle - noteAngle);
        let middleAngleDifference = abs(cursorAngle - noteAngle - M_PI*2);
        let upperAngleDifference = abs(cursorAngle - noteAngle + M_PI*2);
        let minAngleDifference = min(lowerAngleDifference, min(middleAngleDifference, upperAngleDifference));
        return minAngleDifference < M_PI/Double(sector);
    }
    
    func updateArea(currTime: Int, sector: Int, dysc: SKSpriteNode) {
        let approachTime = msHit - msAppear;
        let noteAngle = getCurrentNoteAngle(time: currTime, sector: sector);
        let center = dysc.position;
        let dyscRadius = Double(dysc.size.width/2);
        let sectorAngle = M_PI * 2 / Double(sector);
        path = CGPathCreateMutable();
        
        var prevRadius: Double;
        var prevTheta: Double;
        if (currTime > msHit) {
            CGPathMoveToPoint(path, nil, CGFloat(dyscRadius * cos(noteAngle)) + center.x, CGFloat(dyscRadius * sin(noteAngle)) + center.y);
            prevRadius = dyscRadius;
            prevTheta = noteAngle;
        } else {
            let noteTimeFraction = Double(currTime - msAppear) / Double(msHit - msAppear);
            CGPathMoveToPoint(path, nil, center.x + CGFloat(dyscRadius * noteTimeFraction * cos(noteAngle)), center.y + CGFloat(dyscRadius * noteTimeFraction * sin(noteAngle)));
            prevRadius = dyscRadius * noteTimeFraction;
            prevTheta = noteAngle;
        }
        CGPathAddArc(path, nil, center.x, center.y, CGFloat(prevRadius), CGFloat(noteAngle), CGFloat(noteAngle - sectorAngle/2), true);
        var startIndex: Int;
        var nodeDirection: Int = direction;
        for (startIndex = nodes.count-2; startIndex >= 0; startIndex--) {
            if (currTime > nodes[startIndex].ms) {
                for i in 0...startIndex {
                    nodeDirection = nodeDirection + nodes[i].rotation;
                }
                let timeFraction = Double(nodes[startIndex+1].ms - currTime) / Double(approachTime);
                let nodeRadius = lerp(lower: dyscRadius, upper: 0, val: timeFraction);
                let nodeTheta: Double;
                if (currTime + approachTime > nodes[startIndex+1].ms) {
                    nodeTheta = Double(nodeDirection) * sectorAngle;
                } else {
                    nodeTheta = getCurrentNoteAngle(time: currTime+approachTime, sector: sector);
                }
                connectNodesOnPath(path, center: center, sector: sector, startTheta: noteAngle - sectorAngle/2, endTheta: nodeTheta - sectorAngle/2, startRadius: dyscRadius, endRadius: nodeRadius);
                prevRadius = nodeRadius;
                prevTheta = nodeTheta;
                break;
            }
        }
        for (var currIndex = startIndex+1; currIndex < nodes.count; currIndex++) {
            startIndex = currIndex;
            let node = nodes[currIndex];
            let timeFraction = Double(node.ms - currTime) / Double(approachTime);
            if (timeFraction > 1) {
                let endTheta = getCurrentNoteAngle(time: currTime+approachTime, sector: sector);
                connectNodesOnPath(path, center: center, sector: sector, startTheta: prevTheta - sectorAngle/2, endTheta: endTheta - sectorAngle/2, startRadius: prevRadius, endRadius: 0);
                prevRadius = 0;
                prevTheta = endTheta;
                break;
            }
            let nodeRadius = lerp(lower: dyscRadius, upper: 0, val: timeFraction);
            let nodeTheta = Double(nodeDirection) * sectorAngle;
            connectNodesOnPath(path, center: center, sector: sector, startTheta: prevTheta - sectorAngle/2, endTheta: nodeTheta - sectorAngle/2, startRadius: prevRadius, endRadius: nodeRadius);
            prevRadius = nodeRadius;
            prevTheta = nodeTheta;
            nodeDirection = nodeDirection + node.rotation;
        }
        CGPathAddArc(path, nil, center.x, center.y, CGFloat(prevRadius), CGFloat(prevTheta - sectorAngle/2), CGFloat(prevTheta + sectorAngle/2), false);
        for (var currIndex = startIndex-1; currIndex >= 0; currIndex--) {
            let node = nodes[currIndex];
            nodeDirection = nodeDirection - node.rotation;
            let timeFraction = Double(node.ms - currTime) / Double(approachTime);
            if (currTime > node.ms) {
                connectNodesOnPath(path, center: center, sector: sector, startTheta: prevTheta + sectorAngle/2, endTheta: noteAngle + sectorAngle/2, startRadius: prevRadius, endRadius: dyscRadius);
                prevRadius = dyscRadius;
                prevTheta = noteAngle;
                break;
            }
            let nodeRadius = lerp(lower: dyscRadius, upper: 0, val: timeFraction);
            let nodeTheta = Double(nodeDirection) * sectorAngle;
            connectNodesOnPath(path, center: center, sector: sector, startTheta: prevTheta + sectorAngle/2, endTheta: nodeTheta + sectorAngle/2, startRadius: prevRadius, endRadius: nodeRadius);
            prevRadius = nodeRadius;
            prevTheta = nodeTheta;
        }
        CGPathAddArc(path, nil, center.x, center.y, CGFloat(prevRadius), CGFloat(prevTheta + sectorAngle/2), CGFloat(prevTheta), true);
        
        pathNode.path = path;
    }
    
    override func setTiming(timePoint: TimingPoint, appearFor appear: Int) {
        super.setTiming(timePoint, appearFor: appear);
        var currLength = 0.0;
        for i in 0..<count(nodes) {
            nodes[i].ms = msHit + Int(round(currLength * timePoint.msPerBeat));
            currLength += nodes[i].length;
        }
        for (var i = 0.25; i <= currLength; i+=0.25) {
            msTicks.append(msHit + Int(round(i * timePoint.msPerBeat)));
        }
        msEnd = msHit + Int(round(currLength * timePoint.msPerBeat));
    }
    
    override func removeFromParent() {
        pathNode.removeFromParent();
        super.removeFromParent();
    }
    
    private func lerp(#lower: Double, upper: Double, val: Double) -> Double {
        return min(1, max(0, val)) * (upper-lower) + lower;
    }
    
    private func getCurrentNoteAngle(#time: Int, sector: Int) -> Double {
        for i in stride(from: nodes.count-2, through: 0, by: -1) {
            if (nodes[i].ms < time) {
                var currDirection = direction;
                for e in 0..<i {
                    currDirection = currDirection + nodes[e].rotation;
                }
                let timeFraction = Double(time - nodes[i].ms) / Double(nodes[i+1].ms - nodes[i].ms);
                let firstAngle = Double(currDirection) * M_PI * 2 / Double(sector);
                currDirection = currDirection + nodes[i].rotation;
                let secondAngle = Double(currDirection) * M_PI * 2 / Double(sector);
                let noteAngle = lerp(lower: firstAngle, upper: secondAngle, val: timeFraction);
                return noteAngle;
            }
        }
        return Double(direction)*M_PI*2/Double(sector);
    }
    
    private func connectNodesOnPath(path: CGMutablePath!, center: CGPoint, sector: Int, startTheta: Double, endTheta: Double, startRadius: Double, endRadius: Double) {
        let sameRadius = startRadius == endRadius;
        let sameTheta = startTheta == endTheta;
        if (!sameTheta && sameRadius) {  //Arc connection
            CGPathAddArc(path, nil, center.x, center.y, CGFloat(endRadius), CGFloat(startTheta), CGFloat(endTheta), startTheta > endTheta);
        } else if (sameTheta && !sameRadius) {  //Line connection
            CGPathAddLineToPoint(path, nil, CGFloat(endRadius * cos(endTheta)) + center.x, CGFloat(endRadius * sin(endTheta)) + center.y);
        } else if (!sameTheta && !sameRadius) {  //Curve connection
            let dTheta = endTheta - startTheta;
            let dRadius = abs(startRadius - endRadius);
            let numSteps = 32.0;
            var i: Double;
            for (i = 0; i <= numSteps; i++) {
                let r = lerp(lower: startRadius, upper: endRadius, val: i/numSteps);
                let t = lerp(lower: startTheta, upper: endTheta, val: i/numSteps);
                let x = CGFloat(r * cos(t)) + center.x;
                let y = CGFloat(r * sin(t)) + center.y;
                CGPathAddLineToPoint(path, nil, x, y);
            }
        }
    }
}
