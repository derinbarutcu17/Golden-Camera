import SwiftUI

@main
struct GoldenRatioCameraApp: App {
    @StateObject private var environment = AppEnvironment()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(environment)
        }
    }
}
