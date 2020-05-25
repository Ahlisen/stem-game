//
//  ScenekitRepresentable.swift
//  GameNonTemplate
//
//  Created by Marcus Ahlström on 2020-05-25.
//  Copyright © 2020 Marcus Ahlström. All rights reserved.
//

import SwiftUI
import SceneKit

class InstantPanGestureRecognizer: UIPanGestureRecognizer {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if self.state == .began { return }
        super.touchesBegan(touches, with: event)
        self.state = .began
    }

}

struct SceneKitView: UIViewRepresentable {
    let scene: SCNScene
    let world: World

    init() {
        let scene = SCNScene(named: "Hub.scn")!
        self.scene = scene
        world = World(scene: scene)
    }

    func makeUIView(context: Context) -> SCNView {
        self.world.reset()
        let scnView = SCNView()
        scnView.delegate = context.coordinator

        let gesture = InstantPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.didTapView))
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
        var panStartZ: CGFloat?
        var lastPanLocation: SCNVector3?

        init(_ parent: SceneKitView) {
            self.parent = parent
            super.init()
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
                print("Mass: \(draggingNode!.physicsBody!.mass)")

            case .changed:
                guard let panStartZ = panStartZ else { return }
                let location = panGesture.location(in: view)
                let worldTouchPosition = view.unprojectPoint(SCNVector3(location.x, location.y, panStartZ))
                let newPos = SCNVector3(worldTouchPosition.x, worldTouchPosition.y, 0)
                draggingNode?.worldPosition = newPos
                draggingNode?.physicsBody?.isAffectedByGravity = false

            case .ended, .cancelled:
                draggingNode?.physicsBody?.isAffectedByGravity = true
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

class WeightFactory {

    func makeWeight(mass: CGFloat) -> SCNNode {

        let height: CGFloat = 0.5 * log(mass)
        let radius: CGFloat = 0.25 * log(mass)

        let geometry = SCNCylinder(radius: radius, height: height)
        let childNode = SCNNode()
        makeMetal(geometry: geometry)
        childNode.geometry = geometry
        childNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape.init(geometry: geometry, options: nil))
        childNode.physicsBody?.mass = mass
        childNode.physicsBody?.rollingFriction = 0.5
        childNode.physicsBody?.friction = 1
//        childNode.physicsBody?.centerOfMassOffset = SCNVector3(0, -height/4, 0)


        let miniGeo = SCNCylinder(radius: radius/2.5, height: height/2)
        makeMetal(geometry: miniGeo)
        let miniChild = SCNNode(geometry: miniGeo)
        miniChild.pivot = SCNMatrix4MakeTranslation(0, -Float(height/4), 0)
        childNode.addChildNode(miniChild)
        miniChild.transform = SCNMatrix4MakeTranslation(0, Float(height/2), 0)

        return childNode
    }


    func makeMetal(geometry: SCNGeometry) {
        geometry.firstMaterial?.diffuse.contents = UIColor.lightGray
        geometry.firstMaterial?.specular.contents = UIColor.lightGray
        geometry.firstMaterial?.lightingModel = .physicallyBased
        geometry.firstMaterial?.roughness.contents = 0.5
        geometry.firstMaterial?.metalness.contents = 0.5
    }
}
