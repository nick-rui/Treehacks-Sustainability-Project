//
//  TogglePicture.swift
//  Treehacks 2025 Project
//
//  Created by Kesavan Ramakrishnan on 2/16/25.
//

import SwiftUI

struct TogglePicture: View {
    @Environment(AppModel.self) private var appModel
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Button(action: {
            // Call the API without parameters
            NetworkManager.shared.fetchDetections { result in
                switch result {
                case .success(let detectionResponse):
                    appState.objects.removeAll()
                    // Handle the successful response
                    print("Detections: \(detectionResponse.detections)")
                    for detection in detectionResponse.detections {
                        let classifacationResult = ClassificationResult(object: entityMap.mappedItems[detection.object] ?? "Drink can", confidence: detection.confidence, bbox: detection.bbox)
                        appState.objects.append(classifacationResult)
                    }
                case .failure(let error):
                    // Handle the error
                    print("Error: \(error.localizedDescription)")
                }
            }
        }) {
            Text("Clean Up Your Mess!")
                .font(.headline)
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        }
    }
}
