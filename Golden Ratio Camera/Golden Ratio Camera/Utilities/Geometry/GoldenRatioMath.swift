import Foundation
import CoreGraphics

enum GoldenRatioMath {
    static let phi: CGFloat = (1.0 + sqrt(5.0)) / 2.0
    static let invPhi: CGFloat = 1.0 / phi          // ~0.618
    static let invPhiSquared: CGFloat = 1.0 / (phi * phi) // ~0.382
    
    /// Fits a golden rectangle inside a container rect based on the desired orientation.
    static func inscribedGoldenRectangle(in container: CGRect, orientation: SpiralOrientation) -> CGRect {
        guard container.width > 0, container.height > 0 else { return .zero }
        
        let isLandscape: Bool
        switch orientation {
        case .topLeft, .topRight:
            isLandscape = true
        case .bottomRight, .bottomLeft:
            isLandscape = false
        }
        
        var goldenWidth: CGFloat
        var goldenHeight: CGFloat
        
        if isLandscape {
            // Force horizontal golden rectangle
            goldenWidth = container.width
            goldenHeight = container.width / phi
            // If too tall for container
            if goldenHeight > container.height {
                goldenHeight = container.height
                goldenWidth = container.height * phi
            }
        } else {
            // Force vertical golden rectangle
            goldenHeight = container.height
            goldenWidth = container.height / phi
            // If too wide for container
            if goldenWidth > container.width {
                goldenWidth = container.width
                goldenHeight = container.width * phi
            }
        }
        
        let x = container.minX + (container.width - goldenWidth) / 2.0
        let y = container.minY + (container.height - goldenHeight) / 2.0
        
        return CGRect(x: x, y: y, width: goldenWidth, height: goldenHeight)
    }
}
