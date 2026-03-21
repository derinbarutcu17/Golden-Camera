import SwiftUI

struct GoldenSpiralPathBuilder {
    func makePath(
        in rect: CGRect,
        orientation: SpiralOrientation,
        iterations: Int = 9
    ) -> Path {
        var path = Path()
        guard rect.width > 0, rect.height > 0 else { return path }
        
        // Fit a golden rectangle in the provided rect
        let goldenRect = GoldenRatioMath.inscribedGoldenRectangle(in: rect)
        
        var currentRect = goldenRect
        var corner: Corner = firstCorner(for: orientation)
        let winding: Winding = winding(for: orientation) // Fixed warning: changed to 'let'
        
        for i in 0..<iterations {
            let side = min(currentRect.width, currentRect.height)
            let square: CGRect
            let nextRect: CGRect
            
            // Subdivide currentRect into a square and a smaller rectangle
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
            
            // Add arc for this square
            addArc(to: &path, in: square, spiralCorner: corner, winding: winding, isFirst: i == 0)
            
            // Advance to next subdivision
            currentRect = nextRect
            corner = nextCorner(after: corner, winding: winding)
            
            if currentRect.width < 1.0 || currentRect.height < 1.0 { break }
        }
        
        return path
    }
    
    enum Corner { case topLeft, topRight, bottomRight, bottomLeft }
    enum Winding { case clockwise, counterClockwise }
    
    private func firstCorner(for orientation: SpiralOrientation) -> Corner {
        switch orientation {
        case .topLeftCW, .topLeftCCW: return .topLeft
        case .topRightCW, .topRightCCW: return .topRight
        case .bottomRightCW, .bottomRightCCW: return .bottomRight
        case .bottomLeftCW, .bottomLeftCCW: return .bottomLeft
        }
    }
    
    private func winding(for orientation: SpiralOrientation) -> Winding {
        return orientation.rawValue.contains("CW") ? .clockwise : .counterClockwise
    }
    
    private func nextCorner(after corner: Corner, winding: Winding) -> Corner {
        switch (corner, winding) {
        case (.topLeft, .clockwise): return .topRight
        case (.topRight, .clockwise): return .bottomRight
        case (.bottomRight, .clockwise): return .bottomLeft
        case (.bottomLeft, .clockwise): return .topLeft
        case (.topLeft, .counterClockwise): return .bottomLeft
        case (.bottomLeft, .counterClockwise): return .bottomRight
        case (.bottomRight, .counterClockwise): return .topRight
        case (.topRight, .counterClockwise): return .topLeft
        }
    }
    
    private func addArc(to path: inout Path, in rect: CGRect, spiralCorner: Corner, winding: Winding, isFirst: Bool) {
        let startAngle: Angle
        let endAngle: Angle
        let center: CGPoint
        
        // The center is the corner *opposite* to the arc segment within the square.
        switch (spiralCorner, winding) {
        case (.topLeft, .clockwise):
            center = CGPoint(x: rect.maxX, y: rect.maxY)
            startAngle = .degrees(180)
            endAngle = .degrees(270)
        case (.topRight, .clockwise):
            center = CGPoint(x: rect.minX, y: rect.maxY)
            startAngle = .degrees(270)
            endAngle = .degrees(0)
        case (.bottomRight, .clockwise):
            center = CGPoint(x: rect.minX, y: rect.minY)
            startAngle = .degrees(0)
            endAngle = .degrees(90)
        case (.bottomLeft, .clockwise):
            center = CGPoint(x: rect.maxX, y: rect.minY)
            startAngle = .degrees(90)
            endAngle = .degrees(180)
            
        case (.topLeft, .counterClockwise):
            center = CGPoint(x: rect.maxX, y: rect.maxY)
            startAngle = .degrees(90)
            endAngle = .degrees(0)
        case (.bottomLeft, .counterClockwise):
            center = CGPoint(x: rect.maxX, y: rect.minY)
            startAngle = .degrees(180)
            endAngle = .degrees(90)
        case (.bottomRight, .counterClockwise):
            center = CGPoint(x: rect.minX, y: rect.minY)
            startAngle = .degrees(270)
            endAngle = .degrees(180)
        case (.topRight, .counterClockwise):
            center = CGPoint(x: rect.minX, y: rect.maxY)
            startAngle = .degrees(0)
            endAngle = .degrees(270)
        }
        
        // Use path.addArc which handles the line segment from current point automatically if needed.
        path.addArc(
            center: center,
            radius: rect.width,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: winding == .counterClockwise
        )
    }
}
