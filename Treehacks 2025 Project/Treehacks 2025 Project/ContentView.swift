import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            // RealityKit View for 3D Models (This stays even if Immersion is 0)
            RealityView { content in
                addUSDZModel(to: content, modelName: "Scene", position: SIMD3(x: 2, y: 2, z: 2))
            }

            VStack {
                Model3D(named: "Scene", bundle: realityKitContentBundle)
                    .padding(.bottom, 50)

                ToggleImmersiveSpaceButton()

                HStack {
                    Button(action: {
                        appState.pLevel = max(1, appState.pLevel - 1)
                    }) {
                        Text("Decrease Level")
                            .padding()
                            .background(Color.red.opacity(0.8))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }

                    Button(action: {
                        appState.pLevel += 1
                    }) {
                        Text("Increase Level")
                            .padding()
                            .background(Color.blue.opacity(0.8))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }
                .padding(.top, 20)
            }
        }
    }

    func addUSDZModel(to content: RealityViewContent, modelName: String, position: SIMD3<Float> = .zero) {
        do {
            let modelEntity = try Entity.loadModel(named: modelName)
            modelEntity.position = position
            content.add(modelEntity)
            print("USDZ model '\(modelName)' added at position \(position)")
        } catch {
            if let url = Bundle.main.url(forResource: "Food can", withExtension: "usdz") {
                print("USDZ model found at: \(url)")
            } else {
                print("USDZ model not found in bundle.")
            }
        }
    }
}
