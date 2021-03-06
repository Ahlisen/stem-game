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
        let padding: CGFloat = 10

        label = SKLabelNode(text: title)
        label.fontName = "Courier-Bold"
        label.fontSize = 40
        label.fontColor = .white
        label.position = CGPoint(x: label.frame.width / 2 + padding, y: padding)

        super.init()

        addChild(label)

        let size = CGSize(
            width: label.frame.width + 2 * padding,
            height: label.frame.height + 2 * padding)

        path = UIBezierPath(
            roundedRect: CGRect(origin: .zero, size: size),
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

    private let titleLabel: SKLabelNode = {
        let instance = SKLabelNode(text: "Hur mycket väger soppan? ™")
        instance.fontName = "Courier-Bold"
        instance.fontSize = 20
        instance.fontColor = .white
        return instance
    }()

    override init(size: CGSize) {
        super.init(size: size)

        addChild(titleLabel)
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

        titleLabel.position = CGPoint(x: titleLabel.frame.width / 2 + 10, y: size.height - titleLabel.frame.height - 10)
    }
}
