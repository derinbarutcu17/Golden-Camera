import SwiftUI
import AVFoundation

struct CameraControlsView: View {
    @EnvironmentObject var viewModel: CameraViewModel
    
    var body: some View {
        // Bottom Bar wrapped in a non-safe-area ignoring view
        VStack(spacing: 15) {
            // Primary Shutter and Bottom Controls
            HStack {
                    // Gallery
                    Button(action: {
                        if let url = URL(string: "photos-redirect://") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.black)
                    }
                    
                    Spacer()
                    
                    // Mode
                    Button(action: { viewModel.nextOverlayMode() }) {
                        Image(systemName: "circle.grid.3x3.fill")
                            .font(.title2)
                            .foregroundColor(viewModel.overlayMode == .goldenSpiral ? .yellow : .white)
                            .frame(width: 50, height: 50)
                            .background(Color.black)
                    }
                    
                    Spacer()
                    
                    // Shutter
                    Button(action: { viewModel.capturePhoto() }) {
                        ZStack {
                            Circle()
                                .fill(.white)
                                .frame(width: 65, height: 65)
                            
                            Circle()
                                .stroke(.white, lineWidth: 3)
                                .frame(width: 75, height: 75)
                        }
                    }
                    .disabled(viewModel.isCapturing)
                    .opacity(viewModel.isCapturing ? 0.5 : 1.0)
                    .frame(width: 75, height: 75)
                    
                    Spacer()
                    
                    // Rotate
                    Button(action: { viewModel.rotateSpiral() }) {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.title2)
                            .foregroundColor(viewModel.isRotatedVertical ? .yellow : .white)
                            .frame(width: 50, height: 50)
                            .background(Color.black)
                    }
                    .opacity(viewModel.overlayMode == .goldenSpiral ? 1 : 0.3)
                    
                    Spacer()
                    
                    // Reflect
                    Button(action: { viewModel.toggleReflection() }) {
                        Image(systemName: "flip.horizontal.fill")
                            .font(.title2)
                            .foregroundColor(viewModel.isReflected ? .yellow : .white)
                            .frame(width: 50, height: 50)
                            .background(Color.black)
                    }
                    .opacity(viewModel.overlayMode == .goldenSpiral ? 1 : 0.3)
                }
                .padding(.horizontal, 15)
                .padding(.bottom, 30) // Extra padding for home indicator
        }
        .background(Color.black)
    }
}
