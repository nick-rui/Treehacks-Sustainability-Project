//
//  Treehacks_2025_ProjectApp.swift
//  Treehacks 2025 Project
//
//  Created by Feolu Kolawole on 2/15/25.
//

import SwiftUI

@main
struct Treehacks_2025_ProjectApp: App {

    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
     }
}
