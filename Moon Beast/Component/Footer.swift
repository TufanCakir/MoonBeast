//
//  Footer.swift
//  Moon Beast
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
        case .home: "icon_pixel_house"
        case .sprites: "sprite_cookieman"
        case .summon: "icon_pixel_crystal"
        case .shop: "icon_pixel_box"
        case .trade: "icon_pixel_trade"
        }
    }
}

struct Footer: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 20) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 4) {
                        Image(tab.imageName)
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()

                        Text(tab.title)
                            .font(.system(size: 13, weight: .bold))
                            .shadow(color: .black.opacity(0.9), radius: 3, x: 0, y: 2)
                            .shadow(color: .black.opacity(0.9), radius: 3, x: 0, y: 2)


                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        AppBackground()
        Footer(selectedTab: .constant(.home))
    }
}
