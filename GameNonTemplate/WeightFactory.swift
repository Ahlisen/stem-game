//
//  WeightFactory.swift
//  GameNonTemplate
//
//  Created by Marcus Ahlström on 2020-05-26.
//  Copyright © 2020 Marcus Ahlström. All rights reserved.
//

import SceneKit

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
