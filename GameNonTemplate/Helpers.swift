//
//  Helpers.swift
//  GameNonTemplate
//
//  Created by Marcus Ahlström on 2020-05-26.
//  Copyright © 2020 Marcus Ahlström. All rights reserved.
//

import UIKit
import SceneKit

class InstantPanGestureRecognizer: UIPanGestureRecognizer {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if self.state == .began { return }
        super.touchesBegan(touches, with: event)
        self.state = .began
    }

}

func makeGold(geometry: SCNGeometry) {
    geometry.firstMaterial?.diffuse.contents = UIColor.init(red: 255/255, green: 229/255, blue: 158/255, alpha: 1)
    geometry.firstMaterial?.specular.contents = UIColor.white
    geometry.firstMaterial?.lightingModel = .physicallyBased
    geometry.firstMaterial?.roughness.contents = 0
    geometry.firstMaterial?.metalness.contents = 1
}
