//
//  World.swift
//  GameNonTemplate
//
//  Created by Marcus Ahlström on 2020-05-25.
//  Copyright © 2020 Marcus Ahlström. All rights reserved.
//

import SceneKit

class ScaleWorld {
    let scene: SCNScene
    let weightFactory = WeightFactory()
    var tilemap: Tilemap
    var cameraNode: SCNNode
    var secondCameraNode: SCNNode

    init(scene: SCNScene) {
        self.scene = scene
        self.tilemap = Tilemap.init()
        
        cameraNode = self.scene.rootNode.childNode(withName: "camera", recursively: true)!
        secondCameraNode = self.scene.rootNode.childNode(withName: "secondCamera", recursively: true)!
    }

    func reset() {
        for x in 0..<tilemap.width {
            for y in 0..<tilemap.height {
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

        let scale = AnalogScale(scene: scene)
        scale.createScale()
        let scalePosition = scale.weightScale.position
        moveCamera(position: scalePosition)

        for x in 1..<10 {
            let childNode = weightFactory.makeWeight(mass: CGFloat(x))
            scene.rootNode.addChildNode(childNode)

            let mass = childNode.physicsBody!.mass
            childNode.transform = SCNMatrix4MakeTranslation(Float(x)/10*Float(mass)-2, 0, 1.5)
        }
    }
    
    func moveCamera(position: SCNVector3) {
        cameraNode.look(at: position)
        
        let animationDuration = 1.5
        cameraNode.camera?.orthographicScale = 20 // TODO: ta bort :)
        SCNTransaction.begin()
        SCNTransaction.animationDuration = animationDuration
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction.init(name: .easeOut)
        cameraNode.camera?.orthographicScale = 4.5
        SCNTransaction.commit()
        
        let finalPosition = position - SCNVector3.init(0, -1, -5)
        let move = SCNAction.move(to: finalPosition, duration: animationDuration)
        let rotate = SCNAction.rotateTo(x: -.pi/6, y: 0, z: 0, duration: animationDuration)
        let actionGroup = SCNAction.group([move, rotate])
        actionGroup.timingMode = .easeOut
        cameraNode.runAction(actionGroup)
    }
}
