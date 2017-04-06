//
//  InputSwitch.swift
//  Paint The Sky
//
//  Created by Charles Ferreira on 01/04/17.
//  Copyright © 2017 Charles Ferreira. All rights reserved.
//

import SpriteKit

public class InputSwitch {
    
    public enum State {
        case velocity
        case density
    }
    
    var baseNode = SKNode()
    var background: SKShapeNode
    var label: SKLabelNode
    var state = State.density
    
    public init(size: CGSize, parent: SKNode) {
        // creates base node
        parent.addChild(baseNode)
        
        // creates background shape
        background = SKShapeNode(rectOf: size, cornerRadius: 5)
        background.fillColor = .blue
        background.alpha = 0.5
        background.position = CGPoint(x: 20 + size.width / 2, y: 20 + size.height / 2)
        baseNode.addChild(background)
        
        // creates label node
        label = SKLabelNode(text: "")
        label.verticalAlignmentMode = .center
        label.fontName = "Avenir-Black"
        label.fontSize = 12
        label.position = background.position
        baseNode.addChild(label)
        updateLabel()
    }
    
    public func pressed(at position: CGPoint) -> Bool {
        if background.contains(position) {
            state = state == .density ? .velocity : .density
            updateLabel()
            return true
        }
        
        return false
    }
    
    func updateLabel() {
        var text: String
        var color: UIColor
        
        switch state {
        case .density:
            text = "Density"
            color = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        case .velocity:
            text = "Velocity"
            color = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        }
        
        label.text = text
        background.fillColor = color
    }
}
