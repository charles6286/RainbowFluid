import SpriteKit
import PlaygroundSupport

public class App {
    public static func run(size frameSize: CGSize, cols: Int, rows: Int,
                           viscosity: CGFloat = 0, diffusion: CGFloat = 0) {
        
        Config.set(cols, rows, viscosity, diffusion)
        
        let myFrame = CGRect(origin: CGPoint(), size: frameSize)
        let myView = SKView(frame: myFrame)
        let myScene = MyScene(size: myFrame.size)
        myView.presentScene(myScene)
        myView.showsFPS = true
        myView.showsNodeCount = true
        
        PlaygroundPage.current.liveView = myView
        PlaygroundPage.current.needsIndefiniteExecution = true
    }
}
