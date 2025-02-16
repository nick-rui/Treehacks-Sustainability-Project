import SwiftUI
import RealityKit
import RealityKitContent

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @Environment(AppModel.self) private var appModel

    var body: some View {
        VStack(spacing: 20) {
            // 3D or 2D content in the window
            Model3D(named: "Scene", bundle: realityKitContentBundle)
                .padding(.bottom, 50)

            // Existing button toggles the "mainImmersive" space
            ToggleImmersiveSpaceButton()

            // NEW button toggles the "lifeImmersive" space
            ToggleLifeSpaceButton()

            // Example pLevel controls
            HStack {
                Button("Decrease Level") {
                    appState.pLevel = max(1, appState.pLevel - 1)
                }
                .padding()
                .background(Color.red.opacity(0.8))
                .foregroundColor(.white)
                .clipShape(Capsule())

                Button("Increase Level") {
                    appState.pLevel += 1
                }
                .padding()
                .background(Color.blue.opacity(0.8))
                .foregroundColor(.white)
                .clipShape(Capsule())
            }
        }
        .padding()
    }
}

