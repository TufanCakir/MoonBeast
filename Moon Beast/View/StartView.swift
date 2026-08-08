//
//  StartView.swift
//  Project Pixel
//
//  Created by Tufan Cakir on 07.08.26.
//

import SwiftUI

struct StartView: View {
    @Binding var hasStartedGame: Bool

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 36) {
                Image("moon_beast_logo")
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(maxWidth: 300)

                Button {
                    hasStartedGame = true
                } label: {
                    Text("Start")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.black)
                        .frame(width: 180, height: 56)
                        .background(.cyan)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 32)
        }
    }
}

struct PlaceholderTabView: View {
    let title: String
    let systemImage: String

    var body: some View {
        ZStack {
            AppBackground()

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

#Preview("Start") {
    StartView(hasStartedGame: .constant(false))
}

#Preview("Placeholder") {
    PlaceholderTabView(title: "Preview", systemImage: "sparkles")
}
