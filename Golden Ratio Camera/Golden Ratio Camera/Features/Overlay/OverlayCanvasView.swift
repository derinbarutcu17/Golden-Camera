import SwiftUI

struct OverlayCanvasView: View {
    let mode: OverlayMode
    let orientation: SpiralOrientation
    let style: OverlayStyle
    
    var body: some View {
        Canvas { context, size in
            let rect = CGRect(origin: .zero, size: size)
            
            var path: Path
            
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
            
            context.stroke(
                path,
                with: .color(style.color.color.opacity(style.opacity)),
                lineWidth: style.lineWidth
            )
        }
    }
}
