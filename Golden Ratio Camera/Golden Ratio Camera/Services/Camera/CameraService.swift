@preconcurrency import AVFoundation
import SwiftUI
import Combine

class CameraService: NSObject, ObservableObject {
    @MainActor @Published var session = AVCaptureSession()
    @MainActor @Published var isSetup = false
    @MainActor @Published var permissionState: CameraPermissionState = .undetermined
    
    private let sessionQueue = DispatchQueue(label: "com.derin.GoldenRatioCamera.sessionQueue")
    private var photoOutput = AVCapturePhotoOutput()
    private var videoInput: AVCaptureDeviceInput?
    
    // Add orientation tracking
    private var windowScene: UIWindowScene? {
        UIApplication.shared.connectedScenes.first as? UIWindowScene
    }
    
    override init() {
        super.init()
        Task { @MainActor in
            checkPermission()
        }
    }
    
    @MainActor
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionState = .authorized
            setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                Task { @MainActor in
                    self.permissionState = granted ? .authorized : .denied
                    if granted {
                        self.setupSession()
                    }
                }
            }
        case .denied, .restricted:
            permissionState = .denied
        @unknown default:
            permissionState = .denied
        }
    }
    
    @MainActor
    private func setupSession() {
        guard !isSetup else { return }
        let session = self.session
        let photoOutput = self.photoOutput
        
        sessionQueue.async {
            session.beginConfiguration()
            
            if session.canSetSessionPreset(.photo) {
                session.sessionPreset = .photo
            }
            
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
                session.commitConfiguration()
                return
            }
            
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
                Task { @MainActor in
                    self.videoInput = videoInput
                }
            }
            
            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
            }
            
            session.commitConfiguration()
            
            Task { @MainActor in
                self.isSetup = true
                self.startSession()
            }
        }
    }
    
    @MainActor
    func startSession() {
        guard !session.isRunning else { return }
        let session = self.session
        sessionQueue.async {
            session.startRunning()
        }
    }
    
    @MainActor
    func stopSession() {
        guard session.isRunning else { return }
        let session = self.session
        sessionQueue.async {
            session.stopRunning()
        }
    }
    
    @MainActor
    func capturePhoto(delegate: AVCapturePhotoCaptureDelegate) {
        let photoOutput = self.photoOutput
        
        // Update rotation angle before capture (iOS 17+)
        if let photoConnection = photoOutput.connection(with: .video) {
            if let videoDevice = videoInput?.device {
                let coordinator = AVCaptureDevice.RotationCoordinator(device: videoDevice, previewLayer: nil)
                let rotationAngle = coordinator.videoRotationAngleForHorizonLevelCapture
                if photoConnection.isVideoRotationAngleSupported(rotationAngle) {
                    photoConnection.videoRotationAngle = rotationAngle
                }
            }
        }
        
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: delegate)
    }
}
