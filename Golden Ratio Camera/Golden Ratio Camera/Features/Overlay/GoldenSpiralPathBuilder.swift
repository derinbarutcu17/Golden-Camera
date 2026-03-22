import SwiftUI

struct GoldenSpiralPathBuilder {
    func makePath(
        in rect: CGRect,
        iterations: Int = 9
    ) -> Path {
        var basePath = Path()
        guard rect.width > 0, rect.height > 0 else { return basePath }
        
        let isPortrait = rect.height > rect.width
        let phi = GoldenRatioMath.phi
        let width, height: CGFloat
        
        if isPortrait {
            width = rect.width
            height = rect.width * phi
        } else {
            height = rect.height
            width = rect.height * phi
        }
        
        let goldenRect = CGRect(
            x: rect.minX + (rect.width - width) / 2,
            y: rect.minY + (rect.height - height) / 2,
            width: width,
            height: height
        )
        
        var currentRect = goldenRect
        var corner: Corner = .topLeft
        
        for _ in 0..<iterations {
            let side = min(currentRect.width, currentRect.height)
            let square: CGRect
            let nextRect: CGRect
            
            switch corner {
            case .topLeft:
                square = CGRect(x: currentRect.minX, y: currentRect.minY, width: side, height: side)
                nextRect = CGRect(x: currentRect.minX + (currentRect.width > currentRect.height ? side : 0),
                                  y: currentRect.minY + (currentRect.width > currentRect.height ? 0 : side),
                                  width: currentRect.width - (currentRect.width > currentRect.height ? side : 0),
                                  height: currentRect.height - (currentRect.width > currentRect.height ? 0 : side))
            case .topRight:
                square = CGRect(x: currentRect.maxX - side, y: currentRect.minY, width: side, height: side)
                nextRect = CGRect(x: currentRect.minX,
                                  y: currentRect.minY + (currentRect.width > currentRect.height ? 0 : side),
                                  width: currentRect.width - (currentRect.width > currentRect.height ? side : 0),
                                  height: currentRect.height - (currentRect.width > currentRect.height ? 0 : side))
            case .bottomRight:
                square = CGRect(x: currentRect.maxX - side, y: currentRect.maxY - side, width: side, height: side)
                nextRect = CGRect(x: currentRect.minX,
                                  y: currentRect.minY,
                                  width: currentRect.width - (currentRect.width > currentRect.height ? side : 0),
                                  height: currentRect.height - (currentRect.width > currentRect.height ? 0 : side))
            case .bottomLeft:
                square = CGRect(x: currentRect.minX, y: currentRect.maxY - side, width: side, height: side)
                nextRect = CGRect(x: currentRect.minX + (currentRect.width > currentRect.height ? side : 0),
                                  y: currentRect.minY,
                                  width: currentRect.width - (currentRect.width > currentRect.height ? side : 0),
                                  height: currentRect.height - (currentRect.width > currentRect.height ? 0 : side))
            }
            
            basePath.addRect(square)
            addArc(to: &basePath, in: square, spiralCorner: corner)
            
            currentRect = nextRect
            // Next corner always advances clockwise mathematically
            corner = nextCorner(after: corner)
            
            if currentRect.width < 0.01 || currentRect.height < 0.01 { break }
        }
        
        return basePath
    }
    
    enum Corner { case topLeft, topRight, bottomRight, bottomLeft }
    
    private func nextCorner(after corner: Corner) -> Corner {
        switch corner {
        case .topLeft: return .topRight
        case .topRight: return .bottomRight
        case .bottomRight: return .bottomLeft
        case .bottomLeft: return .topLeft
        }
    }
    
    private func addArc(to path: inout Path, in rect: CGRect, spiralCorner: Corner) {
        let startAngle: Angle
        let endAngle: Angle
        let center: CGPoint
        
        // The arc connects the outer corner to the inner boundary corner of the square.
        // We use isReflected for horizontal flip instead of complex winding.
        switch spiralCorner {
        case .topLeft:
            center = CGPoint(x: rect.maxX, y: rect.maxY) // Bottom-Right
            startAngle = .degrees(180)
            endAngle = .degrees(270)
        case .topRight:
            center = CGPoint(x: rect.minX, y: rect.maxY) // Bottom-Left
            startAngle = .degrees(270)
            endAngle = .degrees(0) // or 360
        case .bottomRight:
            center = CGPoint(x: rect.minX, y: rect.minY) // Top-Left
            startAngle = .degrees(0)
            endAngle = .degrees(90)
        case .bottomLeft:
            center = CGPoint(x: rect.maxX, y: rect.minY) // Top-Right
            startAngle = .degrees(90)
            endAngle = .degrees(180)
        }
        
        path.addArc(
            center: center,
            radius: rect.width,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
    }
}
