//
//  World.swift
//  GameNonTemplate
//
//  Created by Marcus Ahlström on 2020-05-25.
//  Copyright © 2020 Marcus Ahlström. All rights reserved.
//

import SceneKit

class ScaleWorld {
    private var weights: [SCNNode] = []

    let scene: SCNScene
    let weightFactory = WeightFactory()
    var tilemap: Tilemap
    var secondCameraNode: SCNNode

    init(scene: SCNScene) {
        self.scene = scene
        self.tilemap = Tilemap.init()

//        secondCameraNode = SCNNode()
//        let camera = SCNCamera()
//        camera.vignettingPower = 2
        secondCameraNode = self.scene.rootNode.childNode(withName: "secondCamera", recursively: true)!
//        secondCameraNode.camera = camera
//        secondCameraNode.position = SCNVector3(x: 1, y: 1, z: 15)
//        secondCameraNode.eulerAngles = SCNVector3(x: 0, y: 0, z: 0)
    }

    func setup() {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        cameraNode.position = SCNVector3(0, 0, 15)

        scene.rootNode.addChildNode(secondCameraNode)

//        let customerNode = scene.rootNode.childNode(withName: "customer", recursively: true)!

        for x in 0..<tilemap.height {
            for y in 0..<tilemap.width {
                let thing = tilemap[x, y]
                let node = SCNNode()
                node.pivot = SCNMatrix4MakeTranslation(0, -0.5, 0)
                node.localTranslate(by: SCNVector3.init(x, 0, y))
                let box = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
                node.geometry = box
                switch thing {
                case .floor:
                    node.scale = SCNVector3.init(1, 0.1, 1)
                case .customer:
                    node.scale = SCNVector3.init(1, 2, 1)
                    node.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                case .player:
                    node.scale = SCNVector3.init(1, 2, 1)
                    node.geometry?.firstMaterial?.diffuse.contents = UIColor.green
                case .bench:
                    node.scale = SCNVector3.init(1, 1, 1)
                    node.geometry?.firstMaterial?.diffuse.contents = UIColor.brown
                }
                scene.rootNode.addChildNode(node)
            }
        }

        AnalogScale(scene: scene).createScale()

        addWeights()
    }

    func reset() {
        weights.forEach { $0.removeFromParentNode() }
        weights.removeAll()

        addWeights()
    }

    private func addWeights() {
        let numberOfWeights = 10
        for x in 1...numberOfWeights {
            let childNode = weightFactory.makeWeight(mass: CGFloat(x))
            scene.rootNode.addChildNode(childNode)

            let y = (x) % 3
            let posx = CGFloat(y)*1.3 - 7

            let posy = 0.0
            let posz = Double(numberOfWeights-x) - 6.0
            let pos = SCNVector3(Double(posx), posy, posz)
            childNode.transform = SCNMatrix4MakeTranslation(pos.x, pos.y, pos.z)

            weights.append(childNode)
        }
    }
}
