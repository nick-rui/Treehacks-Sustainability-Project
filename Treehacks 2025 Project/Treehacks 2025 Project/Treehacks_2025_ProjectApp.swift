import SwiftUI

@main
struct Treehacks_2025_ProjectApp: App {
    @State private var immersionStyle: ImmersionStyle = .progressive(1.0...1.0, initialAmount: 0.0)
    @StateObject private var appState = AppState() // Shared environment object
    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState) // Inject environment object
                .environment(appModel)
        }

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appState) // Inject environment object
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: $immersionStyle, in: .progressive)
    }
}

@Observable
class AppState: ObservableObject {
    var pLevel: Int = 1
}

