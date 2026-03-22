import SwiftUI
import AVFoundation

struct CameraScreen: View {
    @EnvironmentObject var environment: AppEnvironment
    @ObservedObject private var cameraService: CameraService
    @StateObject private var viewModel: CameraViewModel
    
    init(cameraService: CameraService, photoLibraryService: PhotoLibraryService) {
        self.cameraService = cameraService
        _viewModel = StateObject(wrappedValue: CameraViewModel(
            cameraService: cameraService,
            photoLibraryService: photoLibraryService
        ))
    }
    
    // Better way: use a Factory or pass from RootView
    // Let's refine RootView to pass the VM.
    
    var body: some View {
        ZStack {
            if cameraService.permissionState == .authorized {
                cameraContent
            } else {
                PermissionGateView(cameraService: cameraService)
            }
        }
        .sheet(isPresented: $viewModel.showSettings) {
            SettingsSheet()
                .environmentObject(viewModel)
        }
    }
    
    private var cameraContent: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    Button(action: { viewModel.showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(15)
                            .contentShape(Rectangle())
                    }
                    
                    Spacer()
                    
                    Button(action: { viewModel.toggleOverlayVisibility() }) {
                        Image(systemName: viewModel.isOverlayVisible ? "eye.fill" : "eye.slash.fill")
                            .font(.title3)
                            .foregroundColor(viewModel.isOverlayVisible ? .yellow : .white)
                            .padding(15)
                            .contentShape(Rectangle())
                    }
                }
                .padding(.top, 40) // typical notch safe area height
                .background(Color.black)
                
                // Viewfinder tightly matched to mathematically true Golden Ratio (approx 1:1.618)
                let finderWidth = geo.size.width
                let finderHeight = finderWidth * GoldenRatioMath.phi
                
                ZStack(alignment: .bottom) {
                    CameraPreviewView(session: viewModel.session)
                    
                    if cameraService.isSetup && viewModel.isOverlayVisible {
                        OverlayCanvasView(
                            mode: viewModel.overlayMode,
                            isRotatedVertical: viewModel.isRotatedVertical,
                            isReflected: viewModel.isReflected,
                            style: viewModel.overlayStyle
                        )
                        .allowsHitTesting(false)
                    }
                    
                    // Debug Overlay
                    if viewModel.showDebugInfo {
                        OverlayDebugView()
                            .environmentObject(viewModel)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                    
                    // Zoom Slider hovering at the bottom edge of viewfinder
                    CameraZoomSlider()
                        .environmentObject(viewModel)
                        .padding(.bottom, 12)
                }
                .frame(width: finderWidth, height: finderHeight)
                .background(Color.black)
                .clipped()
                
                // Bottom Controls Area exactly as tall as remaining content, totally black!
                CameraControlsView()
                    .environmentObject(viewModel)
                    .frame(maxHeight: .infinity)
                    .background(Color.black)
            }
            .background(Color.black)
            .ignoresSafeArea()
        }
        
        // Toast Notification overlays everything
        .overlay(
            ToastView(message: viewModel.toastMessage, isShowing: $viewModel.showToast)
        )
    }
}
