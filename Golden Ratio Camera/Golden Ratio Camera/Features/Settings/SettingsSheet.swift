import SwiftUI
import Combine

struct SettingsSheet: View {
    @EnvironmentObject var viewModel: CameraViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Export Settings") {
                    Toggle("Save Copy with Overlay", isOn: $viewModel.saveWithOverlay)
                    Toggle("Show Debug Info", isOn: $viewModel.showDebugInfo)
                }
                
                Section("Overlay Style") {
                    Slider(value: $viewModel.overlayStyle.opacity, in: 0.1...1.0) {
                        Text("Opacity")
                    } minimumValueLabel: {
                        Text("0.1")
                    } maximumValueLabel: {
                        Text("1.0")
                    }
                    
                    Stepper("Line Width: \(String(format: "%.1f", viewModel.overlayStyle.lineWidth))", value: $viewModel.overlayStyle.lineWidth, in: 0.5...5.0, step: 0.5)
                }
                
                Section("About") {
                    Text("Golden Ratio Camera helps you compose beautiful photos using mathematical principles.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
