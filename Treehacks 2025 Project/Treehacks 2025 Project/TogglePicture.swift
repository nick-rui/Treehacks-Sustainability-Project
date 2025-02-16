//
//  TogglePicture.swift
//  Treehacks 2025 Project
//
//  Created by Kesavan Ramakrishnan on 2/16/25.
//

import SwiftUI

struct TogglePicture: View {
    var body: some View {
        Button(action: {
            // Call the API without parameters
            NetworkManager.shared.fetchDetections { result in
                switch result {
                case .success(let detectionResponse):
                    // Handle the successful response
                    print("Detections: \(detectionResponse.detections)")
                    for detection in detectionResponse.detections {
                        print("Object: \(detection.object), Confidence: \(detection.confidence), BBox: \(detection.bbox)")
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
