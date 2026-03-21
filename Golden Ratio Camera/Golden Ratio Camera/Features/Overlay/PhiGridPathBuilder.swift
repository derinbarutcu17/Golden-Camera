import SwiftUI

struct PhiGridPathBuilder {
    func makePath(in rect: CGRect) -> Path {
        var path = Path()
        guard rect.width > 0, rect.height > 0 else { return path }
        
        let invPhiSquared = GoldenRatioMath.invPhiSquared // 0.382
        let invPhi = GoldenRatioMath.invPhi               // 0.618
        
        // Vertical lines
        let x1 = rect.minX + rect.width * invPhiSquared
        let x2 = rect.minX + rect.width * invPhi
        
        path.move(to: CGPoint(x: x1, y: rect.minY))
        path.addLine(to: CGPoint(x: x1, y: rect.maxY))
        
        path.move(to: CGPoint(x: x2, y: rect.minY))
        path.addLine(to: CGPoint(x: x2, y: rect.maxY))
        
        // Horizontal lines
        let y1 = rect.minY + rect.height * invPhiSquared
        let y2 = rect.minY + rect.height * invPhi
        
        path.move(to: CGPoint(x: rect.minX, y: y1))
        path.addLine(to: CGPoint(x: rect.maxX, y: y1))
        
        path.move(to: CGPoint(x: rect.minX, y: y2))
        path.addLine(to: CGPoint(x: rect.maxX, y: y2))
        
        return path
    }
}
