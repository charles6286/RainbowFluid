//
//  MyScene.swift
//  Paint The Sky
//
//  Created by Charles Ferreira on 29/03/17.
//  Copyright © 2017 Charles Ferreira. All rights reserved.
//

import SpriteKit

public class MyScene: SKScene {
    
    var fluid = Fluid()
    var previousTime: TimeInterval?
    var currentPosition: CGPoint?
    var previousPosition: CGPoint?
    
    var isChangingMethod = false
    
    var inputSwitch: InputSwitch!
    var resetButton: ResetButton!
    
    public override func didMove(to view: SKView) {
        // prepares the fluid
        fluid.setup(cols: Config.cols, rows: Config.rows,
                    diff: Config.diffusion, visc: Config.viscosity,
                    scene: self)
        
        // add input method switch and reset button
        inputSwitch = InputSwitch(size: CGSize(width: 100, height: 30), parent: self)
        resetButton = ResetButton(size: CGSize(width: 100, height: 30), parent: self)
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // changes input method
        let position = touches.first!.location(in: self)
        
        if inputSwitch.pressed(at: position) {
            isChangingMethod = true
            return
        } else if resetButton.pressed(at: position) {
            inputSwitch.state = .density
            inputSwitch.updateLabel()
            fluid.reset()
        }
        
        // resets touch position
        previousPosition = position
        currentPosition = previousPosition
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isChangingMethod { return }
        
        // updates touch position
        previousPosition = currentPosition
        currentPosition = touches.first!.location(in: self)
        
        // adds density or velocity
        if inputSwitch.state == .density {
            fluid.addDensity(at: currentPosition!)
        } else {
            fluid.addVelocity(from: previousPosition!, to: currentPosition!)
        }
        
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isChangingMethod = false
    }
    
    public override func update(_ currentTime: TimeInterval) {
        // skips first frame since deltaTime would be zero
        guard previousTime != nil else {
            previousTime = currentTime
            return
        }
        
        // calculates the time passed between frames
        let deltaTime = CGFloat(currentTime - previousTime!)
        previousTime = currentTime
        
        // updates fluid simulation
        fluid.update(deltaTime)
        fluid.draw()
    }
    
}
