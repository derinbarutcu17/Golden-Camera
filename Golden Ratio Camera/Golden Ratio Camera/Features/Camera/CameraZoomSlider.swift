import SwiftUI

struct CameraZoomSlider: View {
    @EnvironmentObject var viewModel: CameraViewModel
    @State private var dragOffset: CGFloat = 0
    @State private var initialZoomAtDragStart: CGFloat = 1.0
    
    let levels: [CGFloat] = [0.5, 1.0, 3.0, 5.0]
    
    var body: some View {
        HStack(spacing: 30) {
            ForEach(levels, id: \.self) { level in
                Text(level == 0.5 ? "0.5" : "\(Int(level))x")
                    .font(.subheadline.bold())
                    .foregroundColor(abs(viewModel.currentZoom - level) < 0.2 ? .yellow : .white)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 20)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .gesture(
            DragGesture()
                .onChanged { value in
                    if dragOffset == 0 {
                        initialZoomAtDragStart = viewModel.currentZoom
                    }
                    dragOffset = value.translation.width
                    
                    // Simple linear mapping: 100 pt drag = 1.0 zoom change
                    let delta = dragOffset / 100.0
                    var newZoom = initialZoomAtDragStart + delta
                    newZoom = max(0.5, min(5.0, newZoom)) // Clamp
                    
                    viewModel.setZoom(newZoom)
                }
                .onEnded { _ in
                    dragOffset = 0
                }
        )
    }
}
