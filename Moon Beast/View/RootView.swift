//
//  RootView.swift
//  Moon Beast
//
//  Created by Tufan Cakir on 07.08.26.
//

import SwiftUI

struct RootView: View {
    @State private var progress = GameProgressStore()
    @State private var selectedTab: AppTab = .home
    @State private var activeMode: MenuMode?
    @State private var hasStartedGame = false

    var body: some View {
        currentView
            .statusBarHidden(true)
    }

    @ViewBuilder
    private var currentView: some View {
        if !hasStartedGame {
            StartView(hasStartedGame: $hasStartedGame)
        } else if let activeMode {
            if activeMode == .event {
                eventShell
            } else {
                modeView(activeMode)
            }
        } else {
            tabShell
        }
    }

    @ViewBuilder
    private func modeView(_ mode: MenuMode) -> some View {
        switch mode {
        case .battle:
            GameView(progress: progress) {
                activeMode = nil
            }
        case .event:
            EventView(progress: progress)
        }
    }

    private var tabShell: some View {
        ZStack(alignment: .bottom) {
            selectedTabView

            Footer(selectedTab: $selectedTab)
                .ignoresSafeArea(edges: .bottom)
        }
    }

    private var eventShell: some View {
        ZStack(alignment: .bottom) {
            EventView(progress: progress)

            Footer(
                selectedTab: Binding(
                    get: { selectedTab },
                    set: { newTab in
                        selectedTab = newTab
                        activeMode = nil
                    }
                )
            )
            .ignoresSafeArea(edges: .bottom)
        }
    }

    @ViewBuilder
    private var selectedTabView: some View {
        switch selectedTab {
        case .home:
            MenuView(progress: progress) { activeMode = $0 }
        case .sprites:
            SpriteListView()
        case .summon:
            SummonView(progress: progress)
        case .shop:
            warehouseView()
        case .trade:
            TradeView()
        }
    }
}

#Preview {
    RootView()
}
