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
        ZStack {
            // Live Preview
            CameraPreviewView(session: viewModel.session)
                .ignoresSafeArea()
            
            // Overlay
            if cameraService.isSetup && viewModel.isOverlayVisible {
                OverlayCanvasView(
                    mode: viewModel.overlayMode,
                    orientation: viewModel.spiralOrientation,
                    style: viewModel.overlayStyle
                )
                .allowsHitTesting(false)
            }
            
            // Controls
            CameraControlsView()
                .environmentObject(viewModel)
            
            // Toast Notification
            ToastView(message: viewModel.toastMessage, isShowing: $viewModel.showToast)
            
            // Debug Overlay
            if viewModel.showDebugInfo {
                OverlayDebugView()
                    .environmentObject(viewModel)
            }
        }
    }
}
