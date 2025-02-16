//
//  AppModel.swift
//  Treehacks 2025 Project
//
//  Created by Feolu Kolawole on 2/15/25.
//

import SwiftUI

@MainActor
@Observable
class AppModel: ObservableObject {
    var immersiveSpaceID: String = "mainImmersive"
    var immersiveSpaceState: ImmersiveSpaceState = .closed

    // Add a second state for the "lifeImmersive" space:
    var lifeImmersiveSpaceState: ImmersiveSpaceState = .closed
}

enum ImmersiveSpaceState {
    case open, closed, inTransition
}


