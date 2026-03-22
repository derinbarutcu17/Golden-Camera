import SwiftUI
import CoreGraphics

struct OverlayImageRenderer {
    func renderOverlay(
        on image: UIImage,
        mode: OverlayMode,
        isRotatedVertical: Bool,
        isReflected: Bool,
        style: OverlayStyle
    ) -> UIImage {
        guard mode != .none else { return image }
        
        let imageSize = image.size
        let rendererFormat = UIGraphicsImageRendererFormat()
        rendererFormat.scale = image.scale
        rendererFormat.opaque = false
        let renderer = UIGraphicsImageRenderer(size: imageSize, format: rendererFormat)
        
        let outputImage = renderer.image { context in
            // Draw the original image at its native size. Do not crop.
            image.draw(in: CGRect(origin: .zero, size: imageSize))
            
            // Draw overlay on the full image bounds.
            let rect = CGRect(origin: .zero, size: imageSize)
            let path: Path
            
            switch mode {
            case .goldenSpiral:
                path = GoldenSpiralPathBuilder().makePath(in: rect)
            case .phiGrid:
                path = PhiGridPathBuilder().makePath(in: rect)
            case .thirdsGrid:
                path = ThirdsGridPathBuilder().makePath(in: rect)
            case .none:
                path = Path()
            }
            
            let cgPath = path.cgPath
            let cgContext = context.cgContext
            
            cgContext.saveGState()
            
            var scaleX: CGFloat = 1
            var scaleY: CGFloat = 1
            var transX: CGFloat = 0
            var transY: CGFloat = 0
            
            if isReflected {
                scaleX = -1
                transX = imageSize.width
            }
            if isRotatedVertical {
                scaleY = -1
                transY = imageSize.height
            }
            
            if isReflected || isRotatedVertical {
                cgContext.translateBy(x: transX, y: transY)
                cgContext.scaleBy(x: scaleX, y: scaleY)
            }
            
            cgContext.addPath(cgPath)
            cgContext.setStrokeColor(style.color.color.opacity(style.opacity).cgColor ?? UIColor.white.cgColor)
            cgContext.setLineWidth(style.lineWidth * (imageSize.width / 400)) // Scale line width for high res
            cgContext.setLineCap(.round)
            cgContext.setLineJoin(.round)
            cgContext.strokePath()
            
            cgContext.restoreGState()
        }
        
        return outputImage
    }
}
