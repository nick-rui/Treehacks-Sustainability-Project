import SwiftUI

struct ToggleLifeSpaceButton: View {

    @Environment(AppModel.self) private var appModel

    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    var body: some View {
        Button {
            Task { @MainActor in
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
                 ? "Hide Life Space"
                 : "Show Life Space")
        }
        .disabled(appModel.lifeImmersiveSpaceState == .inTransition)
        .animation(.none, value: 0)
        .fontWeight(.semibold)
    }
}
