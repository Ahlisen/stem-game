//
//  HubScene.swift
//  GameNonTemplate
//
//  Created by Marcus Ahlström on 2020-05-25.
//  Copyright © 2020 Marcus Ahlström. All rights reserved.
//

import Foundation

struct Vector {
    let x: Double
    let y: Double
}

struct Tilemap {
    private let tiles: [GridState]
    public let width: Int

    init(tiles: [GridState] = [], width: Int = 3) {
        self.width = width
        self.tiles = tiles
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
