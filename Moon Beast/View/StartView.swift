//
//  StartView.swift
//  Project Pixel
//
//  Created by Tufan Cakir on 07.08.26.
//

import SwiftUI

struct StartView: View {
    var body: some View {
        PlaceholderTabView(title: "Start", systemImage: "play.fill")
    }
}

struct PlaceholderTabView: View {
    let title: String
    let systemImage: String

    var body: some View {
        ZStack {
            Color(red: 0.01, green: 0.02, blue: 0.05)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 44, weight: .bold))

                Text(title)
                    .font(.system(size: 28, weight: .heavy))
            }
            .foregroundStyle(.white)
        }
    }
}
