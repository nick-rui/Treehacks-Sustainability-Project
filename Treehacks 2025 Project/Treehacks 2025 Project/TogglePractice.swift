//
//  TogglePractice.swift
//  Treehacks 2025 Project
//
//  Created by Kesavan Ramakrishnan on 2/16/25.
//
import SwiftUI

struct TogglePractice: View {
    var body: some View {
        Button(action: {
            print("hello")
        }) {
            Text("Practice Sorting!")
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
        .animation(.none, value: 0)
    }

}
