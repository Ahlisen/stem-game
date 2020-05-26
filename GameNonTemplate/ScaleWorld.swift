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
    var cameraNode: SCNNode
    var secondCameraNode: SCNNode

    init(scene: SCNScene) {
        self.scene = scene
        self.tilemap = Tilemap.init()
        
        cameraNode = self.scene.rootNode.childNode(withName: "camera", recursively: true)!
        secondCameraNode = self.scene.rootNode.childNode(withName: "secondCamera", recursively: true)!
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

        let scale = AnalogScale(scene: scene)
        scale.createScale()
        let scalePosition = scale.weightScale.position
        moveCamera(position: scalePosition)

        addWeights()
        makeSoup()
    }

    func makeSoup() {
        let cylinder = SCNCylinder(radius: 0.5, height: 1.5)
        let cylinderNode = SCNNode(geometry: cylinder)
        let side = SCNMaterial()
        side.diffuse.contents = UIImage(named: "soup")
        side.diffuse.contentsTransform = SCNMatrix4MakeScale(2, 1, 0)
        side.diffuse.wrapS = .repeat
        side.diffuse.wrapT = .repeat
        let top = SCNMaterial()
        top.diffuse.contents = UIImage(named: "canTop")
        let topBottom = SCNMaterial()
        topBottom.diffuse.contents = UIImage(named: "canbottom")
        cylinder.materials = [side, top, topBottom]
        cylinderNode.position = SCNVector3(5, 2, 0)
        cylinderNode.rotation = SCNVector4(0, CGFloat.pi/4, 0, 1)
        cylinderNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: cylinder, options: nil))
        cylinderNode.physicsBody?.collisionBitMask = 1 << 1
        cylinderNode.physicsBody?.categoryBitMask = 1 << 1
        cylinderNode.physicsBody?.contactTestBitMask = 1 << 1
        cylinderNode.physicsBody?.mass = CGFloat(Int.random(in: 1..<10))
        cylinderNode.name = "soup"
        scene.rootNode.addChildNode(cylinderNode)
    }

    func reset() {
        weights.forEach { $0.removeFromParentNode() }
        weights.removeAll()
        scene.rootNode.childNode(withName: "soup", recursively: true)?.removeFromParentNode()

        addWeights()
        makeSoup()
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
    
    func moveCamera(position: SCNVector3) {
        cameraNode.look(at: position)
        
        let animationDuration = 3.5
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
