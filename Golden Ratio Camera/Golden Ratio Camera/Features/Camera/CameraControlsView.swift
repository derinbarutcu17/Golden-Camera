import SwiftUI

struct CameraControlsView: View {
    @EnvironmentObject var viewModel: CameraViewModel
    
    var body: some View {
        VStack {
            // Top Bar
            HStack {
                Button(action: { viewModel.showSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Button(action: { viewModel.toggleOverlayVisibility() }) {
                    Image(systemName: viewModel.isOverlayVisible ? "eye.fill" : "eye.slash.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
            .padding(.top, 50)
            .padding(.horizontal)
            
            Spacer()
            
            // Bottom Bar
            VStack(spacing: 20) {
                // Secondary Controls
                HStack(spacing: 30) {
                    Button(action: { viewModel.nextOverlayMode() }) {
                        VStack(spacing: 4) {
                            Image(systemName: "circle.grid.3x3.fill")
                            Text("Mode")
                                .font(.caption2)
                        }
                        .foregroundColor(.white)
                    }
                    
                    if viewModel.overlayMode == .goldenSpiral {
                        Button(action: { viewModel.rotateSpiral() }) {
                            VStack(spacing: 4) {
                                Image(systemName: "arrow.counterclockwise.circle.fill")
                                Text("Rotate")
                                    .font(.caption2)
                            }
                            .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                
                // Primary Shutter
                HStack {
                    Spacer()
                    
                    Button(action: { viewModel.capturePhoto() }) {
                        ZStack {
                            Circle()
                                .fill(.white)
                                .frame(width: 70, height: 70)
                            
                            Circle()
                                .stroke(.white, lineWidth: 3)
                                .frame(width: 80, height: 80)
                        }
                    }
                    .disabled(viewModel.isCapturing)
                    .opacity(viewModel.isCapturing ? 0.5 : 1.0)
                    
                    Spacer()
                }
                .padding(.bottom, 40)
            }
        }
        .ignoresSafeArea(.all, edges: .top)
    }
}
