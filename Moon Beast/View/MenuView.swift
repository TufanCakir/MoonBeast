//
//  MenuView.swift
//  Moon Beast
//
//  Created by Tufan Cakir on 08.08.26.
//

import SwiftUI

struct MenuView: View {
    let progress: GameProgressStore
    let openMode: (MenuMode) -> Void

    @State private var isModePickerPresented = false

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                GameHeader(
                    progress: progress
                )
                .padding(.top, 8)

                Spacer()

                Button {
                    isModePickerPresented = true
                } label: {
                    Text("Menü")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.9), radius: 3, x: 0, y: 2)
                        .frame(maxWidth: .infinity)
                        .frame(height: 72)
                        .background {
                            Image("icon_pixel_menü")
                                .resizable()
                                .interpolation(.none)
                                .scaledToFill()
                                .shadow(color: .black.opacity(0.9), radius: 3, x: 0, y: 2)
                        }
                                   }
                .buttonStyle(.plain)
                .padding(.horizontal)
                .shadow(color: .black.opacity(0.9), radius: 3, x: 0, y: 2)

                Spacer()
            }

            if isModePickerPresented {
                modePickerOverlay
            }
        }
    }

    private var modePickerOverlay: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture {
                    isModePickerPresented = false
            }

            VStack(spacing: 50) {
                popupButton(
                    title: "Battle",
                    iconImage: "sprite_cookieman",
                    backgroundImage: "ground_colorfull",
                    mode: .battle
                )
                popupButton(
                    title: "Events",
                    iconImage: "sprite_cookieman",
                    backgroundImage: "ground_colorfull",
                    mode: .event
                )
            }
            .padding(.horizontal, 50)
            .padding(.vertical, 50)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.01, green: 0.44, blue: 0.78).opacity(0.92),
                        Color(red: 0.16, green: 0.22, blue: 0.24).opacity(0.86),
                        Color(red: 0.39, green: 0.40, blue: 0.38).opacity(0.92)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .overlay {
                RoundedRectangle(cornerRadius: 42)
                    .stroke(.blue, lineWidth: 2)
            }
            .clipShape(RoundedRectangle(cornerRadius: 42))
            .padding(.horizontal, 36)
        }
    }

    private func popupButton(
        title: String,
        iconImage: String,
        backgroundImage: String,
        mode: MenuMode
    ) -> some View {
        Button {
            isModePickerPresented = false
            openMode(mode)
        } label: {
            HStack(spacing: 20) {
                Image(iconImage)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 34, height: 34)

                Text(title)
                    .font(.system(size: 24, weight: .bold))
                    .shadow(color: .black.opacity(0.9), radius: 3, x: 0, y: 2)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 74)
            .background {
                Image(backgroundImage)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFill()
                    .opacity(0.72)
            }
            .overlay {
                Capsule()
                    .stroke(.yellow, lineWidth: 2)
            }
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

enum MenuMode {
    case battle
    case event
}

#Preview {
    MenuView(progress: GameProgressStore()) { _ in }
}
