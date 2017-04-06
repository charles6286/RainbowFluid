/*:
 # Rainbow
 ## Fluid simulation
 
 Real-time fluid simulation based on Alexander McKenzie's semi-Lagrangian implementation (2004) for a fluid solver as proposed by Jos Stam in Stable Fluid (1999).
 
 Find more information in [Caltech's Multi-Res Modeling Group](http://www.multires.caltech.edu/teaching/demos/java/stablefluids.htm).
 
 ### Instructions
1. Tweak numbers below
2. Click and drag in the view on the right to change add Dye or Velocity
 */
import SpriteKit

let frameSize = CGSize(width: 400, height: 600)
let cols = 60
let rows = 72
let diffusion = CGFloat(0.00000001)
let viscosity = CGFloat(0.00000000)

App.run(size: frameSize, cols: cols, rows: rows, viscosity: viscosity, diffusion: diffusion)
