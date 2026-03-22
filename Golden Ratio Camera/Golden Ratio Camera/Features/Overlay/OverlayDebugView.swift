import SwiftUI

struct OverlayDebugView: View {
    @EnvironmentObject var viewModel: CameraViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Debug Info")
                .font(.headline)
            Text("Mode: \(viewModel.overlayMode.localizedName)")
            Text("Is Rotated: \(String(describing: viewModel.isRotatedVertical))")
            Text("Opacity: \(String(format: "%.2f", viewModel.overlayStyle.opacity))")
            
            if viewModel.overlayMode == .goldenSpiral {
                Text("Golden Rect: Stretched FullBounds")
            }
        }
        .padding()
        .background(.black.opacity(0.7))
        .cornerRadius(10)
        .foregroundColor(.white)
        .font(.caption)
        .padding()
    }
}
