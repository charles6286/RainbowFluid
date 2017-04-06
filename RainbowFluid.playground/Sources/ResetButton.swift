//
//  InputSwitch.swift
//  Paint The Sky
//
//  Created by Charles Ferreira on 01/04/17.
//  Copyright © 2017 Charles Ferreira. All rights reserved.
//

import SpriteKit

// duplicate from Input Switch. No time to create a super class etc.
public class ResetButton {
    
    var baseNode = SKNode()
    var background: SKShapeNode
    var label: SKLabelNode
    
    public init(size: CGSize, parent: SKNode) {
        // creates base node
        parent.addChild(baseNode)
        
        // creates background shape
        background = SKShapeNode(rectOf: size, cornerRadius: 5)
        background.fillColor = .red
        background.alpha = 0.5
        background.position = CGPoint(x: 20 + size.width / 2, y: 40 + size.height)
        baseNode.addChild(background)
        
        // creates label node
        label = SKLabelNode(text: "Reset")
        label.verticalAlignmentMode = .center
        label.fontName = "Avenir-Black"
        label.fontSize = 12
        label.position = background.position
        baseNode.addChild(label)
    }
    
    public func pressed(at position: CGPoint) -> Bool {
        return background.contains(position)
    }
}
