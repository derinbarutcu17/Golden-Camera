import SwiftUI
import Photos
import Combine
import AVFoundation

@MainActor
class CameraViewModel: NSObject, ObservableObject {
    @Published var overlayMode: OverlayMode = .goldenSpiral
    @Published var isRotatedVertical: Bool = false
    @Published var overlayStyle: OverlayStyle = .defaultStyle
    @Published var isOverlayVisible: Bool = true
    @Published var isReflected: Bool = false
    @Published var isCapturing: Bool = false
    @Published var showSettings: Bool = false
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""
    @Published var saveWithOverlay: Bool = false
    @Published var showDebugInfo: Bool = false
    @Published var currentZoom: CGFloat = 1.0
    
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
        isRotatedVertical.toggle()
    }
    
    func toggleReflection() {
        isReflected.toggle()
    }
    
    func setZoom(_ level: CGFloat) {
        currentZoom = level
        cameraService.setZoom(level)
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
        
        let renderer = OverlayImageRenderer()
        let processedImage: UIImage
        
        if saveWithOverlay {
            processedImage = renderer.renderOverlay(
                on: image,
                mode: overlayMode,
                isRotatedVertical: isRotatedVertical,
                isReflected: isReflected,
                style: overlayStyle
            )
        } else {
            processedImage = renderer.renderOverlay(
                on: image,
                mode: .none,
                isRotatedVertical: isRotatedVertical,
                isReflected: isReflected,
                style: overlayStyle
            )
        }
        
        photoLibraryService.saveImage(processedImage)
        
        // Success feedback
        toastMessage = "Saved to Photos"
        withAnimation { showToast = true }
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
