//
//  Footer.swift
//  Project Pixel
//
//  Created by Tufan Cakir on 07.08.26.
//

import SwiftUI

enum AppTab: CaseIterable {
    case battle
    case sprites
    case summon
    case trade
    case warehouse
    case room

    var title: String {
        switch self {
        case .battle: "Battle"
        case .sprites: "Sprites"
        case .summon: "Summon"
        case .trade: "Trade"
        case .warehouse: "Bag"
        case .room: "Room"
        }
    }

    var systemImage: String {
        switch self {
        case .battle: "flame.fill"
        case .sprites: "person.3.fill"
        case .summon: "sparkles"
        case .trade: "arrow.left.arrow.right"
        case .warehouse: "shippingbox.fill"
        case .room: "square.grid.2x2.fill"
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
                        Image(systemName: tab.systemImage)
                            .font(.system(size: 20, weight: .heavy))

                        Text(tab.title)
                            .font(.system(size: 11, weight: .heavy))
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    .foregroundStyle(selectedTab == tab ? .cyan : .white.opacity(0.72))
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .padding(.bottom, 22)
        .background(
            .black.opacity(0.72),
            in: UnevenRoundedRectangle(
                topLeadingRadius: 18,
                topTrailingRadius: 18
            )
        )
        .overlay(alignment: .top) {
            Rectangle()
                .fill(.cyan.opacity(0.35))
                .frame(height: 1)
        }
    }
}
