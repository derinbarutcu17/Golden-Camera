import SwiftUI
import CoreGraphics

struct OverlayImageRenderer {
    func renderOverlay(
        on image: UIImage,
        mode: OverlayMode,
        orientation: SpiralOrientation,
        style: OverlayStyle
    ) -> UIImage {
        guard mode != .none else { return image }
        
        let imageSize = image.size
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        
        let outputImage = renderer.image { context in
            // Draw original image
            image.draw(at: .zero)
            
            // Draw overlay
            let rect = CGRect(origin: .zero, size: imageSize)
            let path: Path
            
            switch mode {
            case .goldenSpiral:
                path = GoldenSpiralPathBuilder().makePath(in: rect, orientation: orientation)
            case .phiGrid:
                path = PhiGridPathBuilder().makePath(in: rect)
            case .thirdsGrid:
                path = ThirdsGridPathBuilder().makePath(in: rect)
            case .none:
                path = Path()
            }
            
            let cgPath = path.cgPath
            let cgContext = context.cgContext
            
            cgContext.addPath(cgPath)
            cgContext.setStrokeColor(style.color.color.opacity(style.opacity).cgColor ?? UIColor.white.cgColor)
            cgContext.setLineWidth(style.lineWidth * (imageSize.width / 400)) // Scale line width for high res
            cgContext.setLineCap(.round)
            cgContext.setLineJoin(.round)
            cgContext.strokePath()
        }
        
        return outputImage
    }
}
