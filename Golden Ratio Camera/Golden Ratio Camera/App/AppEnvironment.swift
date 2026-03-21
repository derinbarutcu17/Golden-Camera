import SwiftUI
import Combine

@MainActor
class AppEnvironment: ObservableObject {
    @Published var cameraService: CameraService
    @Published var photoLibraryService: PhotoLibraryService
    
    init() {
        self.cameraService = CameraService()
        self.photoLibraryService = PhotoLibraryService()
    }
}
