@preconcurrency import AVFoundation
import SwiftUI
import Combine

class CameraService: NSObject, ObservableObject {
    @MainActor @Published var session = AVCaptureSession()
    @MainActor @Published var isSetup = false
    @MainActor @Published var permissionState: CameraPermissionState = .undetermined
    var zoomScaleFactor: CGFloat = 1.0
    
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
            
            var videoDevice: AVCaptureDevice?
            
            let deviceTypes: [AVCaptureDevice.DeviceType] = [
                .builtInTripleCamera,
                .builtInDualWideCamera,
                .builtInDualCamera,
                .builtInWideAngleCamera
            ]
            
            let discoverySession = AVCaptureDevice.DiscoverySession(
                deviceTypes: deviceTypes,
                mediaType: .video,
                position: .back
            )
            
            videoDevice = discoverySession.devices.first
            var systemZoomScale: CGFloat = 1.0
            if videoDevice?.deviceType == .builtInTripleCamera || videoDevice?.deviceType == .builtInDualWideCamera {
                systemZoomScale = 2.0
            } else if videoDevice?.deviceType == .builtInDualCamera {
                systemZoomScale = 1.0
            }
            
            guard let videoDevice = videoDevice,
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
                photoOutput.isHighResolutionCaptureEnabled = true
            }
            
            let finalZoomScale = systemZoomScale
            session.commitConfiguration()
            
            Task { @MainActor in
                self.zoomScaleFactor = finalZoomScale
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
        let session = self.session
        sessionQueue.async {
            session.stopRunning()
        }
    }
    
    @MainActor
    func setZoom(_ factor: CGFloat) {
        let session = self.session
        sessionQueue.async {
            // Use local captured session instead of self.session (MainActor-isolated)
            
            // Determine physical lens
            let targetDeviceType: AVCaptureDevice.DeviceType
            var relativeZoom: CGFloat
            
            if factor < 1.0 {
                targetDeviceType = .builtInUltraWideCamera
                relativeZoom = factor / 0.5 // e.g. 0.5x -> 1.0 zoom
            } else if factor < 3.0 {
                targetDeviceType = .builtInWideAngleCamera
                relativeZoom = factor // e.g. 1.0x -> 1.0 zoom
            } else {
                targetDeviceType = .builtInTelephotoCamera
                // e.g. 3.0x UI -> 1.0 on Telephoto
                // Or if it's a 5x device: Apple abstracts 3x telephoto versus 5x telephoto.
                relativeZoom = factor / 3.0 
            }
            
            // Find current device
            let currentDevice = self.videoInput?.device
            var deviceToConfigure = currentDevice
            
            // Need device swap?
            if currentDevice?.deviceType != targetDeviceType {
                if let newDevice = AVCaptureDevice.default(targetDeviceType, for: .video, position: .back) {
                    do {
                        let newInput = try AVCaptureDeviceInput(device: newDevice)
                        session.beginConfiguration()
                        if let currentInput = self.videoInput {
                            session.removeInput(currentInput)
                        }
                        if session.canAddInput(newInput) {
                            session.addInput(newInput)
                            Task { @MainActor in
                                self.videoInput = newInput
                            }
                            deviceToConfigure = newDevice
                        } else {
                            if let currentInput = self.videoInput { session.addInput(currentInput) }
                        }
                        session.commitConfiguration()
                    } catch {
                        print("Failed to swap camera: \(error)")
                    }
                } else {
                    // Fallback to wide angle with digital zoom
                    if targetDeviceType == .builtInTelephotoCamera || targetDeviceType == .builtInUltraWideCamera {
                        // User requested a lens that does not exist physically (e.g. simulator or base iPhone)
                        // Use WideAngle and scale digitally
                        if targetDeviceType == .builtInUltraWideCamera {
                            relativeZoom = 1.0 // Can't zoom out
                        } else {
                            relativeZoom = factor // 3x digital zoom
                        }
                    }
                }
            }
            
            // Set video zoom factor
            guard let activeDevice = deviceToConfigure else { return }
            do {
                try activeDevice.lockForConfiguration()
                if activeDevice.isRampingVideoZoom { activeDevice.cancelVideoZoomRamp() }
                activeDevice.videoZoomFactor = max(activeDevice.minAvailableVideoZoomFactor, min(relativeZoom, activeDevice.maxAvailableVideoZoomFactor))
                activeDevice.unlockForConfiguration()
            } catch {
                print("Failed to set videoZoomFactor: \(error)")
            }
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
        if photoOutput.isHighResolutionCaptureEnabled {
            settings.isHighResolutionPhotoEnabled = true
        }
        if #available(iOS 13.0, *) {
            settings.photoQualityPrioritization = .quality
        }
        photoOutput.capturePhoto(with: settings, delegate: delegate)
    }
}
