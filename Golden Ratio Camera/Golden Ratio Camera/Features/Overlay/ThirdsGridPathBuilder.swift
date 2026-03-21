import SwiftUI

struct ThirdsGridPathBuilder {
    func makePath(in rect: CGRect) -> Path {
        var path = Path()
        guard rect.width > 0, rect.height > 0 else { return path }
        
        // Vertical lines
        for i in 1...2 {
            let x = rect.minX + rect.width * CGFloat(i) / 3.0
            path.move(to: CGPoint(x: x, y: rect.minY))
            path.addLine(to: CGPoint(x: x, y: rect.maxY))
        }
        
        // Horizontal lines
        for i in 1...2 {
            let y = rect.minY + rect.height * CGFloat(i) / 3.0
            path.move(to: CGPoint(x: rect.minX, y: y))
            path.addLine(to: CGPoint(x: rect.maxX, y: y))
        }
        
        return path
    }
}
