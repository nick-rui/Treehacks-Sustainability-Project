import SwiftUI
import RealityKit
import RealityKitContent

struct LifeView: View {
    @EnvironmentObject var appState: AppState
    @Environment(AppModel.self) private var appModel

    static var trash = Entity()
    static var recycle = Entity()
    static var trashRect = ModelEntity()
    static var recycleRect = ModelEntity()

    @State private var collisionSubscription: EventSubscription?
    @State private var entityCategories: [ObjectIdentifier: String] = [:]

    var body: some View {
        RealityView { content in
            if let skybox = createSkybox(named: "Sky") {
                print("Skybox Loaded")
                skybox.name = "SkyBox"
                content.add(skybox)
            }

            
            // 1) Load "Forest"
            if let forest = createForest(named: "Forest \(Int(appState.fLevel.rounded()))") {
                forest.name = "ForestEntity"
                content.add(forest)
            }

            // 2) Floor plane (static)
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

            // 3) Load at most 8 items from appState.objects
            for classification in appState.objects.prefix(10) {
                let modelName = classification.object
                do {
                    // Attempt to load the asset named modelName
                    let entity = try await Entity(named: modelName)

                    // If entityMap has an entry, apply scale + collision
                    if let entry = entityMap.map[modelName] {
                        let (scale, _, collisionRadius, category) = (
                            entry.scale,
                            entry.position,
                            entry.collisionRadius,
                            entry.category
                        )
                        entity.scale = scale

                        // Random spawn angle in [0, 2π), distance in [0.5, 1.5)
                        let angle = Float.random(in: 0 ..< 2 * Float.pi)
                        let radius = Float.random(in: 0.5 ..< 1.5)
                        let x = radius * cos(angle)
                        let z = radius * sin(angle)
                        entity.position = [x, 0.2, z]

                        // For more precise selection, shrink collision radius
                        let smallerRadius = collisionRadius * 0.15
                        let collisionShape = ShapeResource.generateSphere(radius: smallerRadius)

                        // Start as kinematic
                        entity.components.set([
                            CollisionComponent(shapes: [collisionShape], mode: .default),
                            InputTargetComponent(),
                            PhysicsBodyComponent(
                                massProperties: .init(),
                                material: .default,
                                mode: .kinematic
                            )
                        ])

                        // Store the category so we can check it on collision
                        entityCategories[ObjectIdentifier(entity)] = category

                    } else {
                        // No dictionary entry => default transform
                        print("No entry in entityMap for \(modelName). Using random position.")
                        let angle = Float.random(in: 0 ..< 2 * Float.pi)
                        let radius = Float.random(in: 0.5 ..< 1.5)
                        let x = radius * cos(angle)
                        let z = radius * sin(angle)
                        entity.position = [x, 0.2, z]

                        entity.components.set([
                            CollisionComponent(shapes: [.generateSphere(radius: 0.3)], mode: .default),
                            InputTargetComponent(),
                            PhysicsBodyComponent(
                                massProperties: .init(),
                                material: .default,
                                mode: .kinematic
                            )
                        ])

                        // We'll assume "trash" if not in dictionary, or skip storing
                        entityCategories[ObjectIdentifier(entity)] = "trash"
                    }

                    content.add(entity)
                } catch {
                    print("Error loading \(modelName): \(error)")
                }
            }

            // 4) Trash can (static)
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
            }

            // 5) Recycle bin (static)
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
            }

            // 6) Debug boxes (static)
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
            // If forest changed, re-load
            updateForest(content: content)

            // Subscribe collisions once
            if collisionSubscription == nil {
                collisionSubscription = content.subscribe(to: CollisionEvents.Began.self) { event in
                    handleCollision(event: event)
                }
            }
        }
        .onChange(of: appState.fLevel) { _, _ in
            Task {
                updateRealityKitScene()
            }
        }
        // 7) Drag logic: remove dynamic on drag, restore dynamic on end
        .gesture(
            DragGesture()
                .targetedToAnyEntity()
                .onChanged { value in
                    let entity = value.entity
                    guard let parent = entity.parent else { return }

                    // Remove dynamic so it won't drop mid-drag
                    entity.components[PhysicsBodyComponent.self] = nil

                    let newPosition = value.convert(value.location3D, from: .local, to: parent)
                    entity.position = newPosition
                }
                .onEnded { value in
                    let entity = value.entity
                    // Set dynamic so it falls & collides
                    var body = PhysicsBodyComponent(
                        massProperties: .init(),
                        material: .default,
                        mode: .dynamic
                    )
                    body.isAffectedByGravity = true
                    entity.components.set(body)
                }
        )
    }

    // MARK: - "Skybox-like" forest code
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

    private func updateForest(content: RealityViewContent) {
        guard let forestEntity = content.entities.first(where: { $0.name == "ForestEntity" }) else {
            return
        }
        let newName = "Forest \(Int(appState.fLevel.rounded()))"

        if !forestEntity.isCurrentlyNamed(newName) {
            forestEntity.removeFromParent()

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

    private func handleCollision(event: CollisionEvents.Began) {
        let a = event.entityA
        let b = event.entityB

        // If trashRect or recycleRect is one entity, the other is the object
        // We'll remove the object from the scene. If category matches, we increment fLevel by 0.25
        // then clamp to 5.26
        if a == Self.trashRect && b != Self.trashRect {
            // b is the item
            removeEntityIfMatch(b, bin: "trash")
        }
        else if b == Self.trashRect && a != Self.trashRect {
            // a is the item
            removeEntityIfMatch(a, bin: "trash")
        }
        else if a == Self.recycleRect && b != Self.recycleRect {
            removeEntityIfMatch(b, bin: "recycle")
        }
        else if b == Self.recycleRect && a != Self.recycleRect {
            removeEntityIfMatch(a, bin: "recycle")
        }
    }

    /// Remove the entity from the scene. If its category matches `bin`, increment fLevel.
    private func removeEntityIfMatch(_ entity: Entity, bin: String) {
        entity.removeFromParent()

        // Check category
        if let category = entityCategories[ObjectIdentifier(entity)], category == bin {
            appState.fLevel += 0.4
            appState.fLevel = min(appState.fLevel, 5.26)
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
}

// Optional extension
private extension Entity {
    func isCurrentlyNamed(_ newName: String) -> Bool {
        return false
    }
}
