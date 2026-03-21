import Foundation
import CoreGraphics

enum GoldenRatioMath {
    static let phi: CGFloat = (1.0 + sqrt(5.0)) / 2.0
    static let invPhi: CGFloat = 1.0 / phi          // ~0.618
    static let invPhiSquared: CGFloat = 1.0 / (phi * phi) // ~0.382
    
    /// Fits a golden rectangle (width/height = phi or height/width = phi) inside a container rect.
    static func inscribedGoldenRectangle(in container: CGRect) -> CGRect {
        guard container.width > 0, container.height > 0 else { return .zero }
        
        // Target aspect ratio is phi (approx 1.618)
        let containerAspect = container.width / container.height
        
        var goldenWidth: CGFloat
        var goldenHeight: CGFloat
        
        if containerAspect >= phi {
            // Container is wider than a golden rectangle (height-limited)
            goldenHeight = container.height
            goldenWidth = container.height * phi
        } else {
            // Container is taller than a golden rectangle (width-limited)
            goldenHeight = container.width / phi
            goldenWidth = container.width
        }
        
        let x = container.minX + (container.width - goldenWidth) / 2.0
        let y = container.minY + (container.height - goldenHeight) / 2.0
        
        return CGRect(x: x, y: y, width: goldenWidth, height: goldenHeight)
    }
}
