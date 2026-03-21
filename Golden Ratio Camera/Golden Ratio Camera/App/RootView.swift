import SwiftUI

struct RootView: View {
    @EnvironmentObject var environment: AppEnvironment
    
    var body: some View {
        CameraScreen(
            cameraService: environment.cameraService,
            photoLibraryService: environment.photoLibraryService
        )
            .environmentObject(environment)
            .preferredColorScheme(.dark)
    }
}

#Preview {
    RootView()
        .environmentObject(AppEnvironment())
}
