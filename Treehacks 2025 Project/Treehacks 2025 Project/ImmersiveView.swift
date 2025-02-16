import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @EnvironmentObject var appState: AppState // Uses environment variable
    @State private var currentSkybox: Skybox = .defaultSkybox

    var body: some View {
        RealityView { content in
            if let skybox = createSkybox(named: currentSkybox.rawValue + " \(appState.pLevel)") {
                print("Skybox Loaded: \(currentSkybox.rawValue + " \(appState.pLevel)")")
                skybox.name = "SkyBox"
                content.add(skybox)
            }
            
        } update: { content in
            updateSkybox(with: currentSkybox, content: content)
        }
        .onChange(of: appState.pLevel) { _, newValue in
            Task {
                updateRealityKitScene()
            }
        }
    }

    private func createSkybox(named skyboxName: String) -> Entity? {
        let largeSphere = MeshResource.generateSphere(radius: 10)
        var skyboxMaterial = UnlitMaterial()
        
        do {
            let texture = try TextureResource.load(named: skyboxName)
            skyboxMaterial.color = .init(texture: .init(texture))
        } catch {
            print("Failed to create skybox material: \(error)")
            return nil
        }
        
        let skyboxEntity = ModelEntity(mesh: largeSphere, materials: [skyboxMaterial])
        skyboxEntity.transform.scale = SIMD3<Float>(-1, 1, 1)
        
        return skyboxEntity
    }
    
    private func updateSkybox(with newSkybox: Skybox, content: RealityViewContent) {
        guard let skyboxEntity = content.entities.first(where: { $0.name == "SkyBox" }) as? ModelEntity else {
            print("Skybox entity not found.")
            return
        }

        let textureName = newSkybox.rawValue + " \(appState.pLevel)"

        guard let updatedSkyboxTexture = try? TextureResource.load(named: textureName) else {
            print("Invalid skybox name: \(textureName)")
            return
        }

        var updatedSkyboxMaterial = UnlitMaterial()
        updatedSkyboxMaterial.color = .init(texture: .init(updatedSkyboxTexture))

        skyboxEntity.model?.materials = [updatedSkyboxMaterial]
    }

    private func updateRealityKitScene() {
        Task {
            RealityView { content in
                updateSkybox(with: currentSkybox, content: content)
            }
        }
    }
}
