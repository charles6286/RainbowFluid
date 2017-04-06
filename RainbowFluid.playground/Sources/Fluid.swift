//
//  Fluid.swift
//  Paint The Sky
//
//  Created by Charles Ferreira on 29/03/17.
//  Copyright © 2017 Charles Ferreira. All rights reserved.
//

import SpriteKit

public class Fluid {
    
    // grid proportions
    var cols: Int!
    var rows: Int!
    var cellSize: CGSize!
    var cellCount: Int!
    var n: CGFloat!
    
    // fluid main attributes
    var diffusion = CGFloat()
    var viscosity = CGFloat()
    var density = [CGFloat]()
    var velocityX = [CGFloat]()
    var velocityY = [CGFloat]()
    var curl = [CGFloat]()
    
    // auxiliary fluid properties
    var tmpDensity = [CGFloat]()
    var tmpVelocityX = [CGFloat]()
    var tmpVelocityY = [CGFloat]()

    // auxiliary stuff
    var hue = CGFloat()
    var node = SKNode()
    var deltaTime = CGFloat()
    
    // necessary to instantiate the class
    public init() {}
    
    public func setup(cols: Int, rows: Int, diff: CGFloat, visc: CGFloat, scene: SKScene) {
        // sets up the grid
        self.cols = cols
        self.rows = rows
        let frameSize = scene.frame.size
        cellSize = CGSize(
            width: frameSize.width / CGFloat(cols),
            height: frameSize.height / CGFloat(rows))
        cellCount = cols * rows
        n = sqrt(CGFloat(cellCount))
        
        // sets base node to cover all space available
        let size = scene.frame.size
        node.position = CGPoint(x: size.width / 2, y: size.height / 2)
        node.xScale = cellSize.width
        node.yScale = cellSize.height
        scene.addChild(node)
        
        // prepares the fluid main attributes
        diffusion = diff
        viscosity = visc
        reset()
    }
    
    public func update(_ deltaTime: CGFloat) {
        // stores deltatime so that we can use it on asynchronous
        // stuff like responding to touch events
        self.deltaTime = deltaTime
        
        // updates color
        hue = fmod(hue + deltaTime / 60, 1.0)
        
        // updates the simulation
        solveVelocity()
        solveDensity()
    }
    
    public func draw() {
        // simple workaround to minimize node count
        // probably could be done better
        node.removeAllChildren()
        node.addChild(SKSpriteNode(texture: texture))
    }
    
    public func addDensity(at position: CGPoint) {
        // fetches the cell under touch position and
        // adds some density to it
        let index = cellIndex(for: position)
        tmpDensity[index] += 1000
    }
    
    public func addVelocity(from previous: CGPoint, to current: CGPoint) {
        // fetches the cell under touch position and
        // adds some velocity to it
        let velocity = current - previous
        let index = cellIndex(for: previous)
        tmpVelocityX[index] += 50 * velocity.x
        tmpVelocityY[index] += 50 * velocity.y
    }
    
    func calculateBuoyancy(using v: inout [CGFloat]) {
        let a = CGFloat(0.00625)
        let b = CGFloat(0.25)
        
        var temperature = CGFloat()
        for y in 0..<rows {
            for x in 0..<cols {
                temperature += density[index(x, y)]
            }
        }
        
        temperature /= CGFloat(density.count)
        
        for y in 0..<rows {
            for x in 0..<cols {
                let d = density[index(x, y)]
                v[index(x, y)] = a * d - b * (d - temperature)
            }
        }
    }
    
    func calculateCurl(_ x: Int, _ y: Int) -> CGFloat {
        // todo: check X and Y aren't switched
        let du_dy = (velocityX[index(x, y + 1)] - velocityX[index(x, y - 1)]) * 0.5
        let dv_dx = (velocityY[index(x + 1, y)] - velocityY[index(x - 1, y)]) * 0.5
    
        return du_dy - dv_dx;
    }

    
    func confineVorticity(x outX: inout [CGFloat], y outY: inout [CGFloat]) {
        var dw_dx, dw_dy: CGFloat
        var length: CGFloat
        var v: CGFloat
        
        // calculate magnitude of curl for each cell
        for x in 1..<cols - 1 {
            for y in 1..<rows - 1 {
                curl[index(x, y)] = abs(calculateCurl(x, y));
            }
        }
        
        for x in 1..<cols - 1 {
            for y in 1..<rows - 1 {
                // find derivative of the magnitude (n = del |w|)
                dw_dx = (curl[index(x + 1, y)] - curl[index(x - 1, y)]) * 0.5
                dw_dy = (curl[index(x, y + 1)] - curl[index(x, y - 1)]) * 0.5
                
                // falculate vector length
                length = sqrt(dw_dx * dw_dx + dw_dy * dw_dy) + 0.000001
                
                // N = ( n/|n| )
                dw_dx /= length
                dw_dy /= length
                
                v = calculateCurl(x, y)
                
                // N x w
                outX[index(x, y)] = dw_dy * -v;
                outY[index(x, y)] = dw_dx *  v;
            }
        }
    }
    
    func solveVelocity() {
        // adds velocity inputted by user
        addSource(from: tmpVelocityX, to: &velocityX)
        addSource(from: tmpVelocityY, to: &velocityY)
        
        // confines vorticity
        confineVorticity(x: &tmpVelocityX, y: &tmpVelocityY)
        addSource(from: tmpVelocityX, to: &velocityX)
        addSource(from: tmpVelocityY, to: &velocityY)
        
        // adds buoyancy force
        calculateBuoyancy(using: &tmpVelocityY)
        addSource(from: tmpVelocityY, to: &velocityY)
        
        // calculates diffusion in velocity
        swap(&tmpVelocityX, &velocityX)
        swap(&tmpVelocityY, &velocityY)
        diffuse(for: .velocityX, from: tmpVelocityX, to: &velocityX, by: viscosity)
        diffuse(for: .velocityY, from: tmpVelocityY, to: &velocityY, by: viscosity)
        
        // creates incompressible field
        project(vx: &velocityX, vy: &velocityY, aux1: &tmpVelocityX, aux2: &tmpVelocityY)
        
        // calculates velocity advection
        swap(&tmpVelocityX, &velocityX)
        swap(&tmpVelocityY, &velocityY)
        advect(for: .velocityX, from: tmpVelocityX, to: &velocityX, vx: tmpVelocityX, vy: tmpVelocityY)
        advect(for: .velocityY, from: tmpVelocityY, to: &velocityY, vx: tmpVelocityX, vy: tmpVelocityY)
        
        // enforces incompressible field
        project(vx: &velocityX, vy: &velocityY, aux1: &tmpVelocityX, aux2: &tmpVelocityY)
        
        // resets input arrays for next frame
        for i in 0..<cellCount {
            tmpVelocityX[i] = 0
            tmpVelocityY[i] = 0
        }
    }
    
    func solveDensity() {
        addSource(from: tmpDensity, to: &density)
        swap(&density, &tmpDensity)
        
        diffuse(for: .density, from: tmpDensity, to: &density, by: diffusion)
        swap(&density, &tmpDensity)
        
        advect(for: .density, from: tmpDensity, to: &density, vx: velocityX, vy: velocityY)
        
        // clears auxiliary array for next frame
        for i in 0..<tmpDensity.count {
            tmpDensity[i] = 0
        }
    }
    
    func addSource(from src: [CGFloat], to dest: inout [CGFloat]) {
        for i in 0..<src.count {
            dest[i] += src[i] * deltaTime
        }
    }
    
    func diffuse(for operation: Operation, from src: [CGFloat], to dest: inout [CGFloat], by factor: CGFloat) {
        let alpha = deltaTime * factor * CGFloat(cols * rows)
        runLinearSolver(for: operation, from: src, to: &dest, times: alpha, by: 1 + 4 * alpha)
    }
    
    func advect(for operation: Operation, from src: [CGFloat], to dest: inout [CGFloat],
                 vx: [CGFloat], vy: [CGFloat]) {
        var i0, j0, i1, j1: Int
        var x, y, s0, t0, s1, t1: CGFloat
        let nx = CGFloat(cols - 2)
        let ny = CGFloat(rows - 2)
        let dtx = deltaTime * nx
        let dty = deltaTime * ny
        
        for i in 1..<rows - 1 {
            for j in 1..<cols - 1 {
                x = CGFloat(j) - dtx * vx[index(j, i)]
                y = CGFloat(i) - dty * vy[index(j, i)]
                
                if x > nx + 0.5 { x = nx + 0.5 }
                else if x < 0.5 { x = 0.5 }
                
                j0 = Int(x)
                j1 = j0 + 1
                
                if y > ny + 0.5 { y = ny + 0.5 }
                else if y < 0.5 { y = 0.5 }
                
                i0 = Int(y)
                i1 = i0 + 1
                
                s1 = x - CGFloat(j0)
                s0 = 1 - s1
                t1 = y - CGFloat(i0)
                t0 = 1 - t1
                
                let value = s0 * (t0 * src[index(j0, i0)] + t1 * src[index(j0, i1)])
                          + s1 * (t0 * src[index(j1, i0)] + t1 * src[index(j1, i1)])
                dest[index(j, i)] = value
            }
        }
        
        setBoundary(for: operation, on: &dest)
    }
    
    func project(vx: inout [CGFloat], vy: inout [CGFloat], aux1 p: inout [CGFloat], aux2 d: inout [CGFloat]) {
        for y in 1..<rows - 1 {
            for x in 1..<cols - 1 {
                p[index(x, y)] = 0
                d[index(x, y)] = (vx[index(x + 1, y)] - vx[index(x - 1, y)]
                                + vy[index(x, y + 1)] - vy[index(x, y - 1)]) * -0.5 / n
            }
        }
        
        setBoundary(for: .density, on: &d)
        setBoundary(for: .density, on: &p)
        runLinearSolver(for: .density, from: d, to: &p, times: 1, by: 4)
        
        for y in 1..<rows - 1 {
            for x in 1..<cols - 1 {
                vx[index(x, y)] -= 0.5 * n * (p[index(x + 1, y)] - p[index(x - 1, y)])
                vy[index(x, y)] -= 0.5 * n * (p[index(x, y + 1)] - p[index(x, y - 1)])
            }
        }
        
        setBoundary(for: .velocityX, on: &vx)
        setBoundary(for: .velocityY, on: &vy)
    }
    
    func runLinearSolver(for operation: Operation, from src: [CGFloat], to dest: inout [CGFloat],
                         times alpha: CGFloat, by delta: CGFloat) {
        if arc4random_uniform(100) < 80 {
            dest = src
            return
        }
        for _ in 1...20 {
            for x in 1..<cols - 1 {
                for y in 1..<rows - 1 {
                    let sum = dest[index(x - 1, y)] + dest[index(x, y - 1)]
                            + dest[index(x + 1, y)] + dest[index(x, y + 1)]
                    dest[index(x, y)] = (sum * alpha + src[index(x, y)]) / delta
                }
            }
            setBoundary(for: operation, on: &dest)
        }
        
    }
    
    func setBoundary(for operation: Operation, on t: inout [CGFloat]) {
        let horzFactor: CGFloat = operation == .velocityY ? -1 : 1
        let vertFactor: CGFloat = operation == .velocityX ? -1 : 1
        
        let x1 = cols - 1
        let x2 = cols - 2
        let y1 = rows - 1
        let y2 = rows - 2
        
        for x in 0..<cols {
            t[index(x, 0 )] = t[index(x, 1 )] * horzFactor
            t[index(x, y1)] = t[index(x, y2)] * horzFactor
        }
        
        for y in 0..<rows {
            t[index( 0, y)] = t[index( 1, y)] * vertFactor
            t[index(x1, y)] = t[index(x2, y)] * vertFactor
        }
        
        t[index( 0,  0)] = (t[index( 0,  1)] + t[index( 1,  0)]) / 2
        t[index( 0, y1)] = (t[index( 0, y2)] + t[index( 1, y1)]) / 2
        t[index(x1,  0)] = (t[index(x2,  0)] + t[index(x1,  1)]) / 2
        t[index(x1, y1)] = (t[index(x1, y2)] + t[index(x2, y1)]) / 2
    }
    
    func reset() {
        let numCells = rows * cols
        density = [CGFloat](repeating: 0, count: numCells)
        velocityX = density
        velocityY = density
        tmpDensity = density
        tmpVelocityX = density
        tmpVelocityY = density
        curl = density
    }
    
    func cellIndex(for position: CGPoint) -> Int {
        let x = Int(position.x / cellSize.width)
        let y = Int(position.y / cellSize.height)
        return index(x, y)
    }
    
    func index(_ x: Int, _ y: Int) -> Int {
        return x + y * cols
    }
    
    var texture: SKTexture {
        var color: UIColor
        var bytes = [UInt8](repeating: 0, count: cols * rows * 4)
        for y in 0..<rows {
            for x in 0..<cols {
                let i = index(x, y) * 4
                let d = min(255, density[index(x, y)] * 128) / 255
                color = UIColor(hue: hue, saturation: d, brightness: d, alpha: d)
                if let c = color.getRGBAComponents() {
                    bytes[i + 0] = UInt8(min(255, c.r * 255))
                    bytes[i + 1] = UInt8(min(255, c.g * 255))
                    bytes[i + 2] = UInt8(min(255, c.b * 255))
                    bytes[i + 3] = UInt8(min(255, c.a * 255))
                }
            }
        }
        let data = Data(bytes: bytes)
        let texture = SKTexture(data: data, size: CGSize(width: cols, height: rows))
        texture.filteringMode = .nearest
        return texture
    }
}


extension Fluid {
    
    // bounds are treated accordingly to operation
    enum Operation {
        case density
        case velocityX
        case velocityY
    }
    
}
