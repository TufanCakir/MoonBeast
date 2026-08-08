//
//  ArenaConfiguration.swift
//  SpriteSheet
//
//  Created by Tufan Cakir on 29.07.26.
//

import SwiftUI

struct ArenaConfiguration: Decodable {
    let backgroundColor: RGBColor
    let floorHeightRatio: CGFloat
    let characterDepth: CGFloat
    let characterScale: CGFloat
    let characterXPosition: CGFloat
    let animationSpeed: CGFloat
    let glowIntensity: CGFloat
    let gridIntensity: CGFloat
    let scanlineIntensity: CGFloat
    let isAnimated: Bool
    let looks: [ArenaLook]

    static func load(named resourceName: String = "arena") throws
        -> ArenaConfiguration
    {
        try JSONLoader.load(named: resourceName)
    }
}

struct ArenaLook: Decodable {
    let name: String
    let backgroundColor: RGBColor
    let accentColor: RGBColor
    let groundImageName: String?
    let animationSpeed: CGFloat
    let glowIntensity: CGFloat
    let gridIntensity: CGFloat
    let scanlineIntensity: CGFloat
    let isAnimated: Bool
}

struct RGBColor: Decodable {
    let red: Double
    let green: Double
    let blue: Double

    var swiftUIColor: Color {
        Color(red: red, green: green, blue: blue)
    }
}
