//
//  SCNVector3Extensions.swift
//  GameNonTemplate
//
//  Created by Fredrik Berglund on 2020-05-26.
//  Copyright © 2020 Marcus Ahlström. All rights reserved.
//

import Foundation
import SceneKit

public func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3(left.x - right.x, left.y - right.y, left.z - right.z)
}

public func += (left: inout SCNVector3, right: SCNVector3) {
    left = left + right
}

public func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3(left.x - right.x, left.y - right.y, left.z - right.z)
}

public func -= (left: inout SCNVector3, right: SCNVector3) {
    left = left - right
}

public func * (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3(left.x * right.x, left.y * right.y, left.z * right.z)
}

public func *= (left: inout SCNVector3, right: SCNVector3) {
    left = left * right
}
