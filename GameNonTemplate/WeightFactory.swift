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

        let density: CGFloat = 22.0 // OSmium
        // cylinder volume = radius * radius * height, 2 * radius = height (diamter:height = 1:1)
        // volume = radius * radius * radius * 2
        // mass = volume * density
        // density = 1
        // radius = sqrt3(mass/2/density)
        let radius: CGFloat = pow(mass/2/density, 1/3)
        let height = radius * 2

        let geometry = SCNCylinder(radius: radius, height: height)
        let textGeo = SCNText(string: "\(Int(mass))", extrusionDepth: 1)
        textGeo.font = UIFont.boldSystemFont(ofSize: 10)
        makeGold(geometry: textGeo)
        textGeo.firstMaterial?.diffuse.contents = UIColor.darkGray
        let textNode = SCNNode(geometry: textGeo)

        textNode.scale = SCNVector3(0.05, 0.05, 0.05)
        let (min, max) = textNode.boundingBox
        textNode.pivot = SCNMatrix4MakeTranslation((max.x - min.x) / 2, 0, 0)

        let childNode = SCNNode()
        childNode.addChildNode(textNode)
        textNode.position = SCNVector3(0, -0.25, radius*1.1)

        makeMetal(geometry: geometry)
        childNode.geometry = geometry
        childNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape.init(geometry: geometry, options: nil))
        childNode.physicsBody?.collisionBitMask = 1 << 1
        childNode.physicsBody?.categoryBitMask = 1 << 1
        childNode.physicsBody?.contactTestBitMask = 1 << 1
        childNode.physicsBody?.mass = mass
        childNode.physicsBody?.rollingFriction = .infinity
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
        let image = UIImage(named: "soup")
        geometry.firstMaterial?.diffuse.contents = [image, image]
        geometry.firstMaterial?.specular.contents = UIColor.lightGray
        geometry.firstMaterial?.lightingModel = .physicallyBased
        geometry.firstMaterial?.roughness.contents = 0.5
        geometry.firstMaterial?.metalness.contents = 0.5
    }
}
