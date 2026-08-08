//
//  Footer.swift
//  Project Pixel
//
//  Created by Tufan Cakir on 07.08.26.
//

import SwiftUI

enum AppTab: CaseIterable {
    case home
    case sprites
    case summon
    case shop
    case trade

    var title: String {
        switch self {
        case .home: "Home"
        case .sprites: "Sprite"
        case .summon: "Summon"
        case .shop: "Shop"
        case .trade: "Trade"
        }
    }

    var imageName: String {
        switch self {
        case .home: "icon_pixel_coin"
        case .sprites: "sprite_cookieman"
        case .summon: "icon_pixel_crystal"
        case .shop: "icon_pixel_box"
        case .trade: "icon_pixel_coin"
        }
    }
}

struct Footer: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 4) {
                        Image(tab.imageName)
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                            .opacity(selectedTab == tab ? 1 : 0.62)

                        Text(tab.title)
                            .font(.system(size: 11, weight: .heavy))
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                            .shadow(color: .black.opacity(0.9), radius: 2, x: 0, y: 1)
                    }
                    .foregroundStyle(selectedTab == tab ? .yellow : .white.opacity(0.62))
                    .frame(maxWidth: .infinity)
                    .frame(height: 62)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 10)
        .padding(.bottom, 24)
        .background(
            .black.opacity(0.72),
            in: Capsule()
        )
        .padding(.horizontal, 18)
        .padding(.bottom, 14)
        .overlay(alignment: .top) {
            Capsule()
                .stroke(.cyan.opacity(0.5), lineWidth: 2)
                .padding(.horizontal, 18)
                .padding(.bottom, 14)
        }
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        AppBackground()
        Footer(selectedTab: .constant(.home))
    }
}
