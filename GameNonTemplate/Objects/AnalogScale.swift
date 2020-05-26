//
//  Scale.swift
//  GameNonTemplate
//
//  Created by Marcus Ahlström on 2020-05-26.
//  Copyright © 2020 Marcus Ahlström. All rights reserved.
//

import Foundation
import SceneKit

class AnalogScale {

    let scene: SCNScene
    let weightScale: SCNNode

    init(scene: SCNScene) {
        self.scene = scene
        self.weightScale = scene.rootNode.childNode(withName: "weightScale", recursively: true)!
    }

    func createScale() {
        let joint = SCNPhysicsHingeJoint.init(body: weightScale.physicsBody!, axis: SCNVector3.init(1, 0, 0), anchor: SCNVector3.init(0, 0, 0))

        weightScale.physicsBody?.angularDamping = 0.1
        weightScale.physicsBody?.allowsResting = true

        makeGold(geometry: weightScale.geometry!)

        scene.physicsWorld.addBehavior(joint)

        makeDiskAndChains(offset: -2.25)
        makeDiskAndChains(offset: 2.25)
    }

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
        disk.physicsBody?.friction = 100000
        disk.position = SCNVector3(0,0,offset)
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
        sphere.segmentCount = 4
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

}
