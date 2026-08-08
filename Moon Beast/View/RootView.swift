//
//  RootView.swift
//  Project Pixel
//
//  Created by Tufan Cakir on 07.08.26.
//

import SwiftUI

struct RootView: View {
    @State private var selectedTab: AppTab = .battle

    var body: some View {
        ZStack(alignment: .bottom) {
            selectedView
                .ignoresSafeArea()

            Footer(selectedTab: $selectedTab)
                .ignoresSafeArea(edges: .bottom)
        }
    }

    @ViewBuilder
    private var selectedView: some View {
        switch selectedTab {
        case .battle:
            GameView()
        case .sprites:
            SpriteListView()
        case .summon:
            SummonView()
        case .trade:
            TradeView()
        case .warehouse:
            warehouseView()
        case .room:
            RoomView()
        }
    }
}
