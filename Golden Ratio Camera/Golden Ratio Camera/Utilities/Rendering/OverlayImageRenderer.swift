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
        let isPortrait = image.size.height > image.size.width
        let phi = GoldenRatioMath.phi
        
        let targetWidth: CGFloat
        let targetHeight: CGFloat
        
        if isPortrait {
            targetHeight = image.size.height
            targetWidth = targetHeight / phi
        } else {
            targetWidth = image.size.width
            targetHeight = targetWidth / phi
        }
        
        let cropRect = CGRect(
            x: (image.size.width - targetWidth) / 2.0,
            y: (image.size.height - targetHeight) / 2.0,
            width: targetWidth,
            height: targetHeight
        )
        
        // Ensure image fits the new golden rect
        let imageSize = CGSize(width: targetWidth, height: targetHeight)
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        
        let outputImage = renderer.image { context in
            // Draw cropped original image
            let drawRect = CGRect(
                x: -cropRect.origin.x,
                y: -cropRect.origin.y,
                width: image.size.width,
                height: image.size.height
            )
            image.draw(in: drawRect)
            
            // Draw overlay exactly on the cropped bounds
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
