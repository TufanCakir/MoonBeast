//
//  Moon_BeastApp.swift
//  Moon Beast
//
//  Created by Tufan Cakir on 08.08.26.
//

import SwiftUI

@main
struct Moon_BeastApp: App {
    init() {
        FontManager.registerBundledFonts()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
