import SwiftUI

import SwiftUI

struct TogglePractice: View {
    @Environment(AppModel.self) private var appModel
    @EnvironmentObject var appState: AppState

    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    var body: some View {
        Button {
            Task { @MainActor in
                // 1) Populate the first 12 items in appState.objects.
                let first12Keys = Array(entityMap.map.keys.prefix(12))
                
                let classificationResults = first12Keys.map { key in
                    ClassificationResult(
                        object: key,
                        confidence: 1.0,
                        bbox: []
                    )
                }
                
                appState.objects = classificationResults
                print("Populated appState.objects with 12 items: \(first12Keys)")
                
                // 2) Then toggle the lifeImmersive space.
                switch appModel.lifeImmersiveSpaceState {
                case .open:
                    appModel.lifeImmersiveSpaceState = .inTransition
                    await dismissImmersiveSpace()
                    // We'll rely on LifeView.onDisappear to set .closed.

                case .closed:
                    appModel.lifeImmersiveSpaceState = .inTransition
                    // Open the "lifeImmersive" space
                    switch await openImmersiveSpace(id: "lifeImmersive") {
                    case .opened:
                        // We'll rely on LifeView.onAppear to set .open.
                        break
                    case .userCancelled, .error:
                        fallthrough
                    @unknown default:
                        appModel.lifeImmersiveSpaceState = .closed
                    }

                case .inTransition:
                    // Shouldn't happen since the button is disabled in that state.
                    break
                }
            }
        } label: {
            Text(appModel.lifeImmersiveSpaceState == .open
                 ? "Quit Practice."
                 : "Practice Sorting!")
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.green.opacity(0.8), Color.blue.opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        }
        .disabled(appModel.lifeImmersiveSpaceState == .inTransition)
        .animation(.none, value: 0)
        .fontWeight(.semibold)
    }
}

