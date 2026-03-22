import SwiftUI
import AVFoundation
import Combine

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        
        context.coordinator.setupRotationCoordinator(for: view.videoPreviewLayer)
        
        return view
    }
    
    func updateUIView(_ uiView: PreviewView, context: Context) {
        // Rotation is handled via the coordinator now
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject {
        private var rotationCoordinator: AVCaptureDevice.RotationCoordinator?
        private var rotationObservation: AnyCancellable?
        
        @MainActor
        func setupRotationCoordinator(for layer: AVCaptureVideoPreviewLayer) {
            guard let device = layer.session?.inputs.compactMap({ ($0 as? AVCaptureDeviceInput)?.device }).first else { return }
            
            let coordinator = AVCaptureDevice.RotationCoordinator(device: device, previewLayer: layer)
            self.rotationCoordinator = coordinator
            
            // Initial angle
            layer.connection?.videoRotationAngle = coordinator.videoRotationAngleForHorizonLevelPreview
            
            // Observe changes
            rotationObservation = coordinator.publisher(for: \.videoRotationAngleForHorizonLevelPreview)
                .receive(on: RunLoop.main)
                .sink { [weak layer] angle in
                    layer?.connection?.videoRotationAngle = angle
                }
        }
    }
    
    class PreviewView: UIView {
        override class var layerClass: AnyClass {
            return AVCaptureVideoPreviewLayer.self
        }
        
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }
}
