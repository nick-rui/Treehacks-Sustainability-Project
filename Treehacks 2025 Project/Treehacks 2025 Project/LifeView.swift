import SwiftUI
import RealityKit
import RealityKitContent

struct LifeView: View {
    @EnvironmentObject var appState: AppState
    @Environment(AppModel.self) private var appModel

    var body: some View {
        RealityView { content in
            // Load "Pizza box"
            if let immersiveChildEntity = try? await Entity(named: "Pizza box") {
                immersiveChildEntity.scale = [0.0001, 0.0001, 0.0001]
                immersiveChildEntity.position = [0, 1.25, -1.25]
                content.add(immersiveChildEntity)
            }

            // Load "Robot"
            if let immersiveChildEntity = try? await Entity(named: "Robot") {
                immersiveChildEntity.scale = [0.01, 0.01, 0.01]
                immersiveChildEntity.position = [0, 0, 0]
                content.add(immersiveChildEntity)
            }
            
            // Load "Robot"
            if let immersiveChildEntity = try? await Entity(named: "Disposal Plastic Cub") {
                immersiveChildEntity.scale = [0.01, 0.01, 0.01]
                immersiveChildEntity.position = [0, 0, 0]
                content.add(immersiveChildEntity)
            } else {
                print("Error")
            }
        }
        .onAppear {
            appModel.lifeImmersiveSpaceState = .open
        }
        .onDisappear {
            appModel.lifeImmersiveSpaceState = .closed
        }
    }
}

