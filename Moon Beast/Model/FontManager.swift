//
//  FontManager.swift
//  Moon Beast
//
//  Created by Tufan Cakir on 08.08.26.
//

import CoreText
import Foundation
import SwiftUI

enum FontManager {
    static let fallbackFontName = "Asteroid Blaster"

    static func registerBundledFonts() {
        guard
            let enumerator = FileManager.default.enumerator(
                at: Bundle.main.bundleURL,
                includingPropertiesForKeys: nil
            )
        else {
            return
        }

        for case let url as URL in enumerator {
            let fileExtension = url.pathExtension.lowercased()

            guard fileExtension == "ttf" || fileExtension == "otf" else {
                continue
            }

            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}

extension Font {
    static func moonBeast(
        size: CGFloat,
        weight: Font.Weight = .regular
    ) -> Font {
        .custom(FontManager.fallbackFontName, size: size).weight(weight)
    }
}
