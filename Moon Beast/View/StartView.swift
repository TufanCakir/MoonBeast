//
//  StartView.swift
//  Moon Beast
//
//  Created by Tufan Cakir on 07.08.26.
//

import SwiftUI

struct StartView: View {
    @Binding var hasStartedGame: Bool

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                Image("moon_beast_logo")
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(maxWidth: 300)

                Text("Tap to Start")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.9), radius: 3, x: 0, y: 2)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            hasStartedGame = true
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
