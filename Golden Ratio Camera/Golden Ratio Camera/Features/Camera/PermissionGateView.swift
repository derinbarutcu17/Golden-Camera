import SwiftUI

struct PermissionGateView: View {
    @EnvironmentObject var environment: AppEnvironment
    @ObservedObject private var cameraService: CameraService
    
    init(cameraService: CameraService) {
        self.cameraService = cameraService
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "camera.fill")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("Camera Access Required")
                .font(.title)
                .fontWeight(.bold)
            
            Text("This app uses the camera so you can compose photos with golden ratio guides.")
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .foregroundColor(.secondary)
            
            if cameraService.permissionState == .denied {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("Grant Access") {
                    cameraService.checkPermission()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}
