import SwiftUI
import Photos
import Combine

@MainActor
class PhotoLibraryService: ObservableObject {
    @Published var permissionStatus: PHAuthorizationStatus = .notDetermined
    
    init() {
        self.permissionStatus = PHPhotoLibrary.authorizationStatus(for: .addOnly)
    }
    
    func requestPermission() async -> Bool {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        self.permissionStatus = status
        return status == .authorized || status == .limited
    }
    
    func saveImage(_ image: UIImage) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { success, error in
            if !success {
                print("Error saving photo: \(String(describing: error))")
            }
        }
    }
}
