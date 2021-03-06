//
//  ScenekitRepresentable.swift
//  GameNonTemplate
//
//  Created by Marcus Ahlström on 2020-05-25.
//  Copyright © 2020 Marcus Ahlström. All rights reserved.
//

import SwiftUI
import SceneKit
import SpriteKit


struct SceneKitView: UIViewRepresentable {
    private let overlay = Overlay(size: UIScreen.main.bounds.size)

    let scene: SCNScene
    let world: ScaleWorld

    init() {
        let scene = SCNScene(named: "Hub.scn")!
        self.scene = scene
        world = ScaleWorld(scene: scene)
    }

    func makeUIView(context: Context) -> SCNView {
        world.setup()

        overlay.didTapResetButton = { [world] in
            world.reset()
        }

        let scnView = SCNView()
        scnView.delegate = context.coordinator
        scnView.overlaySKScene = overlay

        let gesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.didTapView))
        gesture.cancelsTouchesInView = false
        scnView.addGestureRecognizer(gesture)

//        scnView.pointOfView = world.secondCameraNode
        return scnView
    }

    func updateUIView(_ scnView: SCNView, context: Context) {
        scnView.scene = scene
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        scnView.showsStatistics = true
        scnView.backgroundColor = .green
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, SCNSceneRendererDelegate {
        var parent: SceneKitView
        var draggingNode: SCNNode?
        var mass: CGFloat = 0
        var panStartZ: CGFloat?
        var lastPanLocation: SCNVector3?

        init(_ parent: SceneKitView) {
            self.parent = parent
            super.init()
        }

        func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
            let node = parent.scene.rootNode.childNode(withName: "weightScale", recursively: true)!
            let success = parent.scene.rootNode.childNode(withName: "success", recursively: true)!

            let torque = -node.presentation.eulerAngles.x * 10
            node.physicsBody?.applyTorque(SCNVector4(0, 0, torque, 1.0), asImpulse: false)

            if abs(node.presentation.eulerAngles.x) < 0.1 {
                if parent.world.startMeasuring {
                    success.geometry?.firstMaterial?.diffuse.contents = UIColor.green
                }
            } else {
                parent.world.startMeasuring = true
                success.geometry?.firstMaterial?.diffuse.contents = UIColor.red
            }

        }

        @objc func didTapView(panGesture: UIPanGestureRecognizer) {

            guard let view = panGesture.view as? SCNView else { return }
            let location = panGesture.location(in: view)
            switch panGesture.state {
            case .began:
                guard let hitNodeResult = view.hitTest(location, options: nil).first, hitNodeResult.node.physicsBody != nil, hitNodeResult.node.physicsBody?.type != SCNPhysicsBodyType.static else { return }
                lastPanLocation = hitNodeResult.worldCoordinates
                panStartZ = CGFloat(view.projectPoint(lastPanLocation!).z)
                draggingNode = hitNodeResult.node
//                draggingNode?.geometry?.firstMaterial?.specular.contents = UIColor.green
                draggingNode?.physicsBody?.allowsResting = false
                mass = draggingNode?.physicsBody?.mass ?? 0
                print("Mass: \(draggingNode!.physicsBody!.mass)")
                draggingNode?.physicsBody?.isAffectedByGravity = false
                draggingNode?.physicsBody?.type = .kinematic

            case .changed:
                guard let panStartZ = panStartZ else { return }
                let location = panGesture.location(in: view)
                let worldTouchPosition = view.unprojectPoint(SCNVector3(location.x, location.y, panStartZ))
                let newY = max(0.75, worldTouchPosition.y - worldTouchPosition.z / 2)
                let newZ = -min(0, worldTouchPosition.y - worldTouchPosition.z - 0.75)
                let newPos = SCNVector3(worldTouchPosition.x, newY, newZ)
//                draggingNode?.geometry?.firstMaterial?.specular.contents = UIColor.yellow
                draggingNode?.worldPosition = newPos
                draggingNode?.physicsBody?.isAffectedByGravity = false
                draggingNode?.physicsBody?.type = .kinematic

            case .ended, .cancelled:
//                draggingNode?.geometry?.firstMaterial?.specular.contents = UIColor.red
                draggingNode?.physicsBody?.type = .dynamic
                draggingNode?.physicsBody?.isAffectedByGravity = true
                draggingNode?.physicsBody?.mass = mass
                draggingNode = nil

            default:
                break
            }

        }
    }
}

struct SceneKitView_Previews: PreviewProvider {
    static var previews: some View {
        SceneKitView()
    }
}
