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
        pathNode.strokeColor = UIColor.redColor();
        pathNode.fillColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.3);
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
        let cursorAngle = (angle + M_PI*2) % (M_PI*2);
        let noteAngle = getCurrentNoteAngle(time: time, sector: sector);
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
        
        //Attempt 1:
//        let noteTimeFraction = min(1, Double(currTime - msAppear) / Double(msHit - msAppear));
//        CGPathMoveToPoint(path, nil, center.x + dysc.size.width/2 * CGFloat(noteTimeFraction * cos(noteAngle)), center.y + dysc.size.height/2 * CGFloat(noteTimeFraction * sin(noteAngle)));
//        var currDirection = direction;
//        var prevRadius = Double(dysc.size.width/2);
//        var prevTheta = noteAngle;
//        for node in nodes {
//            if (currTime > node.ms) {
//                currDirection = (currDirection + node.rotation) % sector;
//                continue;
//            } else if (currTime+approachTime < node.ms) {
//                CGPathAddLineToPoint(path, nil, center.x, center.y);
//                break;
//            }
//            let timeFraction = Double(node.ms - currTime) / Double(approachTime);
//            let nodeRadius = lerp(lower: Double(dysc.size.width/2), upper: 0, val: timeFraction);
//            let nodeTheta = Double(currDirection)*M_PI*2/Double(sector);
//            if (node.rotation == 0)  {
//                CGPathAddLineToPoint(path, nil, center.x + CGFloat(nodeRadius * cos(nodeTheta)), center.y + CGFloat(nodeRadius * sin(nodeTheta)));
//            } else {
//                let endTheta = getCurrentNoteAngle(time: min(node.ms+approachTime, currTime+approachTime), sector: sector);
//                NSLog("\(prevTheta)   \(endTheta)");
//                connectNodesOnPath(path, center: CGPoint(x: center.x, y: center.y), sector: sector, startTheta: prevTheta, endTheta: endTheta, startRadius: prevRadius, endRadius: nodeRadius);
//            }
//            prevRadius = nodeRadius;
//            prevTheta = nodeTheta;
//            currDirection = (currDirection + node.rotation) % sector;
//        }
        
        //Attempt 2:
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
                    nodeDirection = (nodeDirection + nodes[i].rotation) % sector;
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
            nodeDirection = (nodeDirection + node.rotation) % sector;
        }
        CGPathAddArc(path, nil, center.x, center.y, CGFloat(prevRadius), CGFloat(prevTheta - sectorAngle/2), CGFloat(prevTheta + sectorAngle/2), false);
        for (var currIndex = startIndex-1; currIndex >= 0; currIndex--) {
            let node = nodes[currIndex];
            nodeDirection = (nodeDirection - node.rotation) % sector;
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
        
        
        CGPathAddArc(path, nil, center.x, center.y, CGFloat(prevRadius), CGFloat(noteAngle + sectorAngle/2), CGFloat(noteAngle), true);
        
        pathNode.path = path;
    }
    
    override func setTiming(timePoint: TimingPoint, appearFor appear: Int) {
        super.setTiming(timePoint, appearFor: appear);
        var currLength = 0.0;
        for i in 0..<count(nodes) {
            nodes[i].ms = msHit + Int(round(currLength * timePoint.msPerBeat));
            currLength += nodes[i].length;
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
                    currDirection = (currDirection + nodes[e].rotation) % sector;
                }
                let timeFraction = Double(time - nodes[i].ms) / Double(nodes[i+1].ms - nodes[i].ms);
                let firstAngle = Double(currDirection) * M_PI * 2 / Double(sector);
                currDirection = (currDirection + nodes[i].rotation) % sector;
                let secondAngle = Double(currDirection) * M_PI * 2 / Double(sector);
                let noteAngle = lerp(lower: firstAngle, upper: secondAngle, val: timeFraction);
                return noteAngle;
            }
        }
        return Double(direction)*M_PI*2/Double(sector);
    }
    
    private func connectNodesOnPath(path: CGMutablePath!, center: CGPoint, sector: Int, startTheta: Double, endTheta: Double, startRadius: Double, endRadius: Double) {
        if (startRadius != endRadius) {
            let dTheta = endTheta - startTheta;
            if (dTheta == 0) {  //Line connection
                CGPathAddLineToPoint(path, nil, CGFloat(endRadius * cos(endTheta)) + center.x, CGFloat(endRadius * sin(endTheta)) + center.y);
            } else {  //Curve connection
//                NSLog("\(startRadius)  \(endRadius)  \(startTheta)  \(endTheta)");
//                let numSteps = 30.0;
//                let step = (endTheta - startTheta)/numSteps;
//                var i: Double;
//                for (i = 0; i <= numSteps; i++) {
//                    let t = startTheta + step*i;
//                    let nextRadius = (startRadius-endRadius)*(t-startTheta)/(2*M_PI/Double(sector));
//                    let x = CGFloat((startRadius - nextRadius) * cos(t)) + center.x;
//                    let y = CGFloat((startRadius - nextRadius) * sin(t)) + center.y;
//                    CGPathAddLineToPoint(path, nil, x, y);
//                }
                
                let dRadius = abs(startRadius - endRadius);
                let x = CGFloat(endRadius * cos(endTheta)) + center.x;
                let y = CGFloat(endRadius * sin(endTheta)) + center.y;
                if (startRadius > endRadius) {
                    let cp1x = CGFloat((startRadius - dRadius/4) * cos(endTheta - dTheta/2)) + center.x;
                    let cp1y = CGFloat((startRadius - dRadius/4) * sin(endTheta - dTheta/2)) + center.y;
                    let cp2x = CGFloat((endRadius + dRadius/8) * cos(endTheta)) + center.x;
                    let cp2y = CGFloat((endRadius + dRadius/8) * sin(endTheta)) + center.y;
                    CGPathAddCurveToPoint(path, nil, cp1x, cp1y, cp2x, cp2y, x, y);
                } else {
                    let cp1x = CGFloat((startRadius + dRadius/8) * cos(startTheta)) + center.x;
                    let cp1y = CGFloat((startRadius + dRadius/8) * sin(startTheta)) + center.y;
                    let cp2x = CGFloat((endRadius - dRadius/4) * cos(startTheta + dTheta/2)) + center.x;
                    let cp2y = CGFloat((endRadius - dRadius/4) * sin(startTheta + dTheta/2)) + center.y;
                    CGPathAddCurveToPoint(path, nil, cp1x, cp1y, cp2x, cp2y, x, y);
                }
            }
        }
//        for (i = 0; i <= numSteps; i++) {
//            let t = startTheta + step*i;
//            let x = CGFloat((startRadius - 2*(startRadius-endRadius)*(t-startTheta)/M_PI) * cos(t))+200;
//            let y = CGFloat((startRadius - 2*(startRadius-endRadius)*(t-startTheta)/M_PI) * sin(t))+300;
//            CGPathAddLineToPoint(path, nil, x, y);
//        }
//        CGPathAddArc(path, nil, 0+200, 0+300, CGFloat(endRadius), CGFloat(startTheta+dTheta), CGFloat(endTheta+dTheta), false);
//        for (i = numSteps; i >= 0; i--) {
//            let t = endTheta + step*i;
//            let x = CGFloat((startRadius - 2*(startRadius-endRadius)*(t-endTheta)/M_PI) * cos(t))+200;
//            let y = CGFloat((startRadius - 2*(startRadius-endRadius)*(t-endTheta)/M_PI) * sin(t))+300;
//            CGPathAddLineToPoint(path, nil, x, y);
//        }
//        CGPathAddArc(path, nil, 0+200, 0+300, CGFloat(startRadius), CGFloat(endTheta), CGFloat(startTheta), true);
    }
}
