import SwiftUI
import Photos
import Combine
import AVFoundation

@MainActor
class CameraViewModel: NSObject, ObservableObject {
    @Published var overlayMode: OverlayMode = .goldenSpiral
    @Published var spiralOrientation: SpiralOrientation = .topLeftCW
    @Published var overlayStyle: OverlayStyle = .defaultStyle
    @Published var isOverlayVisible: Bool = true
    @Published var isCapturing: Bool = false
    @Published var showSettings: Bool = false
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""
    @Published var saveWithOverlay: Bool = false
    @Published var showDebugInfo: Bool = false
    
    private let cameraService: CameraService
    private let photoLibraryService: PhotoLibraryService
    
    init(cameraService: CameraService, photoLibraryService: PhotoLibraryService) {
        self.cameraService = cameraService
        self.photoLibraryService = photoLibraryService
    }
    
    var session: AVCaptureSession {
        cameraService.session
    }
    
    var permissionState: CameraPermissionState {
        cameraService.permissionState
    }
    
    func toggleOverlayVisibility() {
        isOverlayVisible.toggle()
    }
    
    func nextOverlayMode() {
        let allModes = OverlayMode.allCases
        if let index = allModes.firstIndex(of: overlayMode) {
            overlayMode = allModes[(index + 1) % allModes.count]
        }
    }
    
    func rotateSpiral() {
        let orientations = SpiralOrientation.allCases
        if let index = orientations.firstIndex(of: spiralOrientation) {
            spiralOrientation = orientations[(index + 1) % orientations.count]
        }
    }
    
    func capturePhoto() {
        guard !isCapturing else { return }
        isCapturing = true
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        cameraService.capturePhoto(delegate: self)
    }
}

extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        isCapturing = false
        
        if let error = error {
            print("Error capturing photo: \(error)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            return
        }
        
        photoLibraryService.saveImage(image)
        
        if saveWithOverlay {
            let renderer = OverlayImageRenderer()
            let highResWithOverlay = renderer.renderOverlay(
                on: image,
                mode: overlayMode,
                orientation: spiralOrientation,
                style: overlayStyle
            )
            photoLibraryService.saveImage(highResWithOverlay)
        }
        
        // Success feedback
        toastMessage = "Saved to Photos"
        withAnimation { showToast = true }
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
