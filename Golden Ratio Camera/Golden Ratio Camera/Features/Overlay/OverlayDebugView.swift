import SwiftUI

struct OverlayDebugView: View {
    @EnvironmentObject var viewModel: CameraViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Debug Info")
                .font(.headline)
            Text("Mode: \(viewModel.overlayMode.localizedName)")
            Text("Orientation: \(viewModel.spiralOrientation.rawValue)")
            Text("Opacity: \(String(format: "%.2f", viewModel.overlayStyle.opacity))")
            
            if viewModel.overlayMode == .goldenSpiral {
                let rect = GoldenRatioMath.inscribedGoldenRectangle(in: UIScreen.main.bounds)
                Text("Golden Rect: \(Int(rect.width))x\(Int(rect.height))")
                Text("Aspect: \(String(format: "%.3f", rect.width / rect.height))")
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
