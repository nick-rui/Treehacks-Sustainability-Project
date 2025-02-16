import SwiftUI
import RealityKit
import RealityKitContent

struct LifeView: View {
    @EnvironmentObject var appState: AppState
    @Environment(AppModel.self) private var appModel

    // We'll keep the same references for the pizza box and bins.
    static var model = Entity()
    static var trash = Entity()
    static var recycle = Entity()
    static var trashRect = ModelEntity()
    static var recycleRect = ModelEntity()

    @State private var collisionSubscription: EventSubscription?

    var body: some View {
        RealityView { content in
            // 1) Add the "Forest" for visuals, using createForest.
            if let forest = createForest(named: "Forest \(Int(appState.fLevel.rounded()))") {
                print("Forest Loaded: Forest \(Int(appState.fLevel.rounded()))")
                forest.name = "ForestEntity"  // Tag it so we can find/update later
                content.add(forest)
            }

            // 2) Invisible floor plane
            let planeSize: SIMD3<Float> = [25, 0.01, 25]
            let planeShape = ShapeResource.generateBox(size: planeSize)

            let floorEntity = Entity()
            floorEntity.position = [0, 0, 0]
            floorEntity.components.set([
                CollisionComponent(shapes: [planeShape], mode: .default),
                PhysicsBodyComponent(
                    massProperties: .init(),
                    material: .default,
                    mode: .static
                )
            ])
            content.add(floorEntity)

            // 3) "Pizza box" (initially kinematic)
            if let pizzaBox = try? await Entity(named: "Pizza box") {
                let collisionShape = ShapeResource.generateSphere(radius: 2200)
                pizzaBox.position = [0, 0.9, -1]
                pizzaBox.scale = [0.0001, 0.0001, 0.0001]

                pizzaBox.components.set([
                    CollisionComponent(shapes: [collisionShape], mode: .default),
                    InputTargetComponent(),
                    PhysicsBodyComponent(
                        massProperties: .init(),
                        material: .default,
                        mode: .kinematic
                    )
                ])

                Self.model = pizzaBox
                content.add(pizzaBox)
            } else {
                print("Error loading Pizza box")
            }

            // 4) Trash Can
            if let trashCan = try? await Entity(named: "Trash Can") {
                trashCan.position = [0.7125, 0, -1.575]
                trashCan.scale = [0.0035, 0.0035, 0.0035]

                let trashShape = ShapeResource.generateSphere(radius: 625)
                trashCan.components.set([
                    CollisionComponent(shapes: [trashShape], mode: .default),
                    PhysicsBodyComponent(
                        massProperties: .init(),
                        material: .default,
                        mode: .static
                    )
                ])
                Self.trash = trashCan
                content.add(trashCan)
            } else {
                print("Error loading Trash Can")
            }

            // 5) Recycle Bin
            if let recycleBin = try? await Entity(named: "Recycle Bin") {
                recycleBin.position = [-0.3875, 0.15, -1.575]
                recycleBin.scale = [0.0035, 0.0035, 0.0035]

                let recycleShape = ShapeResource.generateSphere(radius: 625)
                recycleBin.components.set([
                    CollisionComponent(shapes: [recycleShape], mode: .default),
                    PhysicsBodyComponent(
                        massProperties: .init(),
                        material: .default,
                        mode: .static
                    )
                ])
                Self.recycle = recycleBin
                content.add(recycleBin)
            } else {
                print("Error loading Recycle Bin")
            }

            // 6) Debug boxes (invisible)
            let invisibleMaterial = SimpleMaterial(color: .clear, isMetallic: false)
            let boxSize: SIMD3<Float> = [0.3, 0.75, 0.3]
            let boxMesh = MeshResource.generateBox(size: boxSize)
            let boxShape = ShapeResource.generateBox(size: boxSize)

            let trashRectEntity = ModelEntity(
                mesh: boxMesh,
                materials: [invisibleMaterial]
            )
            trashRectEntity.position = [0.7125, 0.375, -1.575]
            trashRectEntity.components.set([
                CollisionComponent(shapes: [boxShape], mode: .default),
                PhysicsBodyComponent(
                    massProperties: .init(),
                    material: .default,
                    mode: .static
                )
            ])
            Self.trashRect = trashRectEntity
            content.add(trashRectEntity)

            let recycleRectEntity = ModelEntity(
                mesh: boxMesh,
                materials: [invisibleMaterial]
            )
            recycleRectEntity.position = [-0.3875, 0.375, -1.575]
            recycleRectEntity.components.set([
                CollisionComponent(shapes: [boxShape], mode: .default),
                PhysicsBodyComponent(
                    massProperties: .init(),
                    material: .default,
                    mode: .static
                )
            ])
            Self.recycleRect = recycleRectEntity
            content.add(recycleRectEntity)

        } update: { content in
            // 7) "Update" function: if forest changed, re-load
            updateForest(content: content)

            // Subscribe collisions once
            if collisionSubscription == nil {
                collisionSubscription = content.subscribe(to: CollisionEvents.Began.self) { event in
                    handleCollision(event: event)
                }
            }
        }
        .onChange(of: appState.fLevel) { oldValue, newValue in
            // 8) If fLevel changed, re-run the "update" closure
            Task {
                updateRealityKitScene()
            }
        }
        // Drag gesture
        .gesture(
            DragGesture()
                .targetedToEntity(Self.model)
                .onChanged { value in
                    guard let parent = value.entity.parent else { return }
                    value.entity.position = value.convert(value.location3D, from: .local, to: parent)
                    value.entity.components[PhysicsBodyComponent.self] = nil
                }
                .onEnded { value in
                    var body = PhysicsBodyComponent(
                        massProperties: .init(),
                        material: .default,
                        mode: .dynamic
                    )
                    body.isAffectedByGravity = true
                    value.entity.components.set(body)
                }
        )
    }

    // MARK: - "Skybox-like" Functions

    /// Create the forest entity if it doesn't exist yet
    private func createForest(named forestName: String) -> Entity? {
        do {
            let forest = try Entity.load(named: forestName)
            forest.name = "ForestEntity"
            forest.position = [3, 0, 0]
            forest.scale = [1, 1, 1]
            return forest
        } catch {
            print("Failed to load forest '\(forestName)': \(error)")
            return nil
        }
    }

    /// In the update closure, find the existing "ForestEntity" and update it if needed
    private func updateForest(content: RealityViewContent) {
        guard let forestEntity = content.entities.first(where: { $0.name == "ForestEntity" }) else {
            // No forest found; maybe we just loaded a new one
            return
        }
        let newName = "Forest \(Int(appState.fLevel.rounded()))"

        // If this forest doesn't match the new name, remove & re-load
        if !forestEntity.isCurrentlyNamed(newName) {
            // Remove old forest
            forestEntity.removeFromParent()

            // Attempt to create the new forest
            if let updatedForest = createForest(named: newName) {
                content.add(updatedForest)
            }
        }
    }

    private func updateRealityKitScene() {
        Task {
            RealityView { content in
                updateForest(content: content)
            }
        }
    }

    /// Handle collisions: remove pizza box & increment fLevel
    private func handleCollision(event: CollisionEvents.Began) {
        let a = event.entityA
        let b = event.entityB

        if (a == Self.model && b == Self.trashRect) ||
           (b == Self.model && a == Self.trashRect) ||
            (a == Self.model && b == Self.recycleRect) ||
            (b == Self.model && a == Self.recycleRect)
        {
            Self.model.removeFromParent()
            appState.fLevel += 0.25
            appState.fLevel = min(appState.fLevel, 5.26)
        }
    }
}


// Optional helper extension to compare the "Forest 2" name
private extension Entity {
    func isCurrentlyNamed(_ newName: String) -> Bool {
        // E.g. "ForestEntity" is the entity's name,
        // but we might store the "Forest 2" string in a property if needed
        // For simplicity, let's just always re-load if we want a new forest
        // Or store a custom component with the real "forest name" if you prefer
        return false
    }
}
