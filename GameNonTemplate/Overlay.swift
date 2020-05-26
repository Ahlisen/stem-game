//
//  Overlay.swift
//  GameNonTemplate
//
//  Created by Eric Nilsson on 2020-05-26.
//  Copyright © 2020 Marcus Ahlström. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

final class ButtonNode: SKShapeNode {
    private let label: SKLabelNode

    var tapHandler: (() -> Void)?

    required init(title: String) {
        label = SKLabelNode(text: title)
        label.fontName = "Courier-Bold"
        label.fontSize = 50
        label.fontColor = .white
        label.position = CGPoint(x: label.frame.width / 2, y: 0)

        super.init()

        addChild(label)

        path = UIBezierPath(
            roundedRect: CGRect(origin: .zero, size: label.frame.size),
            cornerRadius: 2).cgPath

        fillColor = .red
        isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        fillColor = .blue
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        fillColor = .red
        tapHandler?()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)

        fillColor = .red
    }
}

class Overlay: SKScene {
    private let resetButton = ButtonNode(title: "RESET")

    var didTapResetButton: (() -> Void)? {
        get { return resetButton.tapHandler }
        set { resetButton.tapHandler = newValue }
    }

    override init(size: CGSize) {
        super.init(size: size)

        addChild(resetButton)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)

        resetButton.position = CGPoint(
            x: size.width - resetButton.frame.width - 10,
            y: size.height - resetButton.frame.height - 10)
    }
}
