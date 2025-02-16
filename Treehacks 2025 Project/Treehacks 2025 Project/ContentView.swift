import SwiftUI
import RealityKit
import RealityKitContent
import AVFoundation

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @Environment(AppModel.self) private var appModel
    
    var body: some View {
        ZStack {
            // Background image
            Image("Background") // Replace with your image name
                .resizable()
                .scaledToFill()
                .ignoresSafeArea() // Ensures the image covers the entire screen
            
            VStack(spacing: 20) {
                // Title
                Text("Welcome to TreeCycle")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 40) // Adds spacing from the top
                
                Spacer() // Pushes the content below the title
                
                // 3D or 2D content in the window
                Model3D(named: "Scene", bundle: realityKitContentBundle)
                    .padding(.bottom, 50)
                
                // Existing button toggles the "mainImmersive" space
                ToggleImmersiveSpaceButton()
                
                // NEW button toggles the "lifeImmersive" space
                ToggleLifeSpaceButton()
                
                // Additional buttons
                TogglePractice()
                
                TogglePicture()
                
                Spacer() // Adds spacing at the bottom
            }
            .padding()
        }
    }
    
}
