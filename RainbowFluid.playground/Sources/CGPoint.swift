//
//  CGPoint.swift
//  Paint The Sky
//
//  Created by Charles Ferreira on 29/03/17.
//  Copyright © 2017 Charles Ferreira. All rights reserved.
//

import SpriteKit

public extension CGPoint {
    public static func - (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }
    
    public static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }
    
    public static func / (left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: left.x / right, y: left.y / right)
    }
    
    public static func += (left: inout CGPoint, right: CGPoint) {
        left = left + right
    }
    
    public static func -= (left: inout CGPoint, right: CGPoint) {
        left = left - right
    }
    
}
