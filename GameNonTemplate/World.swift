//
//  World.swift
//  GameNonTemplate
//
//  Created by Marcus Ahlström on 2020-05-25.
//  Copyright © 2020 Marcus Ahlström. All rights reserved.
//

import SceneKit

class World {
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

    func makeGold(geometry: SCNGeometry) {
        geometry.firstMaterial?.diffuse.contents = UIColor.init(red: 255/255, green: 229/255, blue: 158/255, alpha: 1)
        geometry.firstMaterial?.specular.contents = UIColor.white
        geometry.firstMaterial?.lightingModel = .physicallyBased
        geometry.firstMaterial?.roughness.contents = 0
        geometry.firstMaterial?.metalness.contents = 1
    }

    func reset() {
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

        let weightScale = scene.rootNode.childNode(withName: "weightScale", recursively: true)!

        let joint = SCNPhysicsHingeJoint.init(body: weightScale.physicsBody!, axis: SCNVector3.init(1, 0, 0), anchor: SCNVector3.init(0, 0, 0))

        weightScale.physicsBody?.angularDamping = 0.1
        weightScale.physicsBody?.allowsResting = true

        makeGold(geometry: weightScale.geometry!)

        scene.physicsWorld.addBehavior(joint)



        func makeDiskAndChains(offset: Double) {

            let end1 = makeChain(offset: offset, index: 2)
            let end2 = makeChain(offset: offset, index: 1)
            let end3 = makeChain(offset: offset, index: 0)

            let array = [end1, end2, end3]

            let diskGeo = SCNCylinder(radius: 1, height: 0.2)
            makeGold(geometry: diskGeo)


            let disk = SCNNode(geometry: diskGeo)
            disk.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape.init(geometry: diskGeo, options: nil))
            disk.physicsBody?.mass = 10
            weightScale.addChildNode(disk)


//            let torus = SCNTorus(ringRadius: 1, pipeRadius: 0.1)
//            makeGold(geometry: torus)
//            let torusNode = SCNNode(geometry: torus)
//            torusNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape.init(geometry: torus, options: nil))
//            torusNode.physicsBody?.mass = 0
//            torusNode.physicsBody?.isAffectedByGravity = false
//            disk.addChildNode(torusNode)
//            torusNode.transform = SCNMatrix4MakeTranslation(0, -0.25, 0)

            for (index, end) in array.enumerated() {
                let trueAngle: Double = (.pi * 2 / 3) * Double(index)

                let x = 1 * cos(trueAngle)
                let y = 1 * sin(trueAngle)

                let behaviour = SCNPhysicsBallSocketJoint(bodyA: end!.physicsBody!, anchorA: .init(0, 0, 0), bodyB: disk.physicsBody!, anchorB: .init(x, -0.2, y))
                scene.physicsWorld.addBehavior(behaviour)
            }

        }

        func makeChain(offset: Double, index: Double) -> SCNNode? {
            var previousNode: SCNNode?
            let sphere = SCNSphere()
            sphere.radius = 0.05
            makeGold(geometry: sphere)

            for _ in 0..<22 {
                let nox = SCNNode(geometry: sphere)
                nox.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape.init(geometry: sphere, options: nil))
                nox.physicsBody?.collisionBitMask = 0
//                nox.physicsBody?.isAffectedByGravity = false
                nox.physicsBody?.mass = 0.1
                weightScale.addChildNode(nox)

                if let previousNode = previousNode {
                    let behaviour = SCNPhysicsBallSocketJoint(bodyA: nox.physicsBody!, anchorA: .init(0, 0, 0), bodyB: previousNode.physicsBody!, anchorB: .init(0, 0.1, 0))
                    scene.physicsWorld.addBehavior(behaviour)
                } else {

                    let trueAngle: Double = (.pi * 2 / 3) * Double(index)

                    let x1 = 0.15 * cos(trueAngle)
                    let y = 0.15 * sin(trueAngle)

                    let joint3 = SCNPhysicsHingeJoint.init(bodyA: nox.physicsBody!, axisA: .init(0, 0, 1), anchorA: .init(0, 0, 0), bodyB: weightScale.physicsBody!, axisB: .init(1, 0, 0), anchorB: .init(x1, 0, y + offset))
                    //                let behaviour = SCNPhysicsBallSocketJoint(body: nox.physicsBody!, anchor: .init(0, -0.2, 0))
                    scene.physicsWorld.addBehavior(joint3)
                }

                previousNode = nox
            }

            return previousNode
        }

        makeDiskAndChains(offset: -2.25)
        makeDiskAndChains(offset: 2.25)

//        var previousNode: SCNNode?
//
//        for x in 0..<10 {
//            let sphere = SCNSphere()
//            sphere.radius = 0.1
//            let nox = SCNNode(geometry: sphere)
////            nox.transform = SCNMatrix4MakeTranslation(0, 0, 2)
//            nox.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape.init(geometry: sphere, options: nil))
//            weightScale.addChildNode(nox)
//
//            if let previousNode = previousNode {
//                let behaviour = SCNPhysicsBallSocketJoint(bodyA: nox.physicsBody!, anchorA: .init(0, 0, 0), bodyB: previousNode.physicsBody!, anchorB: .init(0, 0.2, 0))
//                scene.physicsWorld.addBehavior(behaviour)
//            } else {
//                let joint3 = SCNPhysicsHingeJoint.init(bodyA: nox.physicsBody!, axisA: .init(0, 0, 1), anchorA: .init(0, 0, 0), bodyB: weightScale.physicsBody!, axisB: .init(1, 0, 0), anchorB: .init(0.5, 0, -3))
////                let behaviour = SCNPhysicsBallSocketJoint(body: nox.physicsBody!, anchor: .init(0, -0.2, 0))
//                scene.physicsWorld.addBehavior(joint3)
//            }
//
//            previousNode = nox
//        }

//        let animation = CABasicAnimation(keyPath: "transform")
//        animation.fromValue = customerNode.transform
//        animation.toValue = SCNMatrix4Mult(customerNode.transform,SCNMatrix4MakeRotation(.pi,  1, 0, 0.0))
//        animation.duration = 1.5
//        animation.repeatCount = 100
//        customerNode.addAnimation(animation, forKey: nil)
//
        for x in 1..<10 {
            let childNode = weightFactory.makeWeight(mass: CGFloat(x))
            scene.rootNode.addChildNode(childNode)

            let mass = childNode.physicsBody!.mass
            childNode.transform = SCNMatrix4MakeTranslation(Float(x)/10*Float(mass)-2, 0, 1.5)
        }

//        let box = SCNBox()
//        childNode.geometry = box
//        let newNode = childNode.clone()
//        newNode.localTranslate(by: SCNVector3(sqrt(3), 0, 0))
//        scene.rootNode.addChildNode(childNode)
//        scene.rootNode.addChildNode(newNode)
    }
}

struct Vector {
    let x: Double
    let y: Double
}

struct Tilemap {
    private let tiles: [GridState]
    public let width: Int

    init() {
        width = 3
        tiles = []// [1,0,0,3,3,0,0,0,2].compactMap(GridState.init)

    }

    enum GridState: Int {
        case floor
        case customer
        case player
        case bench
    }
}

extension Tilemap {

    var height: Int {
        return tiles.count / width
    }

    subscript(x: Int, y: Int) -> GridState {
        return tiles[y * width + x]
    }
}
