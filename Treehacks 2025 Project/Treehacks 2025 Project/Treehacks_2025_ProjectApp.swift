import SwiftUI

@main
struct Treehacks_2025_ProjectApp: App {
    
    @State private var immersionStyle: ImmersionStyle = .progressive(0...1.0, initialAmount: 1.0)
    @StateObject private var appState = AppState()
    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .environment(appModel)
        }

        // Existing main immersive space
        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appState)
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: $immersionStyle, in: .progressive)

        ImmersiveSpace(id: "lifeImmersive") {
            LifeView()
                .environment(appState)
                .environment(appModel)
                .onAppear {
                    // Mark the second space as open
                    appModel.lifeImmersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.lifeImmersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }
}


@Observable
class AppState: ObservableObject {
    var pLevel: Int = 1
    var myRange: ClosedRange<Double> = 1.0...1.0
}

