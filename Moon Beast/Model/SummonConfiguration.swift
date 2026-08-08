//
//  SummonConfiguration.swift
//  Moon Beast
//
//  Created by Tufan Cakir on 08.08.26.
//

import Foundation
import SwiftUI

struct SummonConfiguration: Decodable {
    let banners: [SummonBanner]

    static func load(named resourceName: String = "summon") throws
        -> SummonConfiguration
    {
        try JSONLoader.load(named: resourceName)
    }
}

struct SummonBanner: Decodable, Identifiable {
    let id: String
    let title: String
    let bannerImageName: String
    let singleCost: Int
    let multiCost: Int
    let multiCount: Int
    let entries: [SummonEntry]
}

struct SummonEntry: Decodable, Identifiable {
    let id: String
    let name: String
    let spriteIndex: Int
    let imageName: String
    let rarity: SpriteRarity
    let weight: Double
}

enum SpriteRarity: String, Codable {
    case common
    case rare
    case epic
    case legendary

    var title: String {
        rawValue.capitalized
    }

    var color: Color {
        switch self {
        case .common:
            .white
        case .rare:
            .cyan
        case .epic:
            .purple
        case .legendary:
            .yellow
        }
    }
}
