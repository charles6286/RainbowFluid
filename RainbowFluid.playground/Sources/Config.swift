import SpriteKit

public class Config {
    static var cols: Int!
    static var rows: Int!
    static var diffusion: CGFloat!
    static var viscosity: CGFloat!
    
    public static func set(_ cols: Int, _ rows: Int, _ diff: CGFloat, _ visc: CGFloat) {
        Config.cols = cols
        Config.rows = rows
        Config.viscosity = visc
        Config.diffusion = diff
    }
}
