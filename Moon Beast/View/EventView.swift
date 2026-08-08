//
//  EventView.swift
//  Moon Beast
//
//  Created by Tufan Cakir on 08.08.26.
//

import SwiftUI

struct EventView: View {
    let progress: GameProgressStore
    let onExit: (() -> Void)?

    private let configuration: EventConfiguration
    @State private var message = ""

    init(
        progress: GameProgressStore,
        configuration: EventConfiguration = try! EventConfiguration.load(),
        onExit: (() -> Void)? = nil
    ) {
        self.progress = progress
        self.configuration = configuration
        self.onExit = onExit
    }

    var body: some View {
        ZStack {
            Image("ground_colorfull")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            Color.black.opacity(0.28)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    Text("Events")
                        .font(.custom("Asteroid Blaster", size: 34))
                        .foregroundStyle(.white)
                        .padding(.top, 62)

                    if !message.isEmpty {
                        Text(message)
                            .font(.system(size: 13, weight: .heavy))
                            .foregroundStyle(.white.opacity(0.8))
                    }

                    ForEach(configuration.events) { event in
                        eventBanner(event)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 110)
            }

            exitButton
                .padding(.leading, 14)
                .padding(.top, 48)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
        }
        .onAppear {
            progress.refreshDailyEventLimits(for: configuration.events)
        }
    }

    private var exitButton: some View {
        Button {
            onExit?()
        } label: {
            Image(systemName: "rectangle.portrait.and.arrow.right")
                .font(.system(size: 17, weight: .heavy))
                .foregroundStyle(.white)
                .frame(width: 42, height: 42)
                .background(.black.opacity(0.62))
        }
        .buttonStyle(.plain)
    }

    private func eventBanner(_ event: GameEvent) -> some View {
        let remainingRuns = progress.remainingRuns(for: event)
        let eventCurrency = progress.eventCurrencies[event.id, default: 0]

        return Button {
            let didFight = progress.fightEvent(event)
            message = didFight ? "\(event.title) cleared" : "Daily limit reached"
        } label: {
            ZStack(alignment: .bottomLeading) {
                Image(event.bannerImageName)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFill()
                    .frame(height: 150)
                    .clipped()

                LinearGradient(
                    colors: [.black.opacity(0.0), .black.opacity(0.78)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(event.title)
                            .font(.system(size: 20, weight: .heavy))

                        Spacer()

                        Text("\(remainingRuns)/\(event.dailyLimit)")
                            .font(.system(size: 13, weight: .heavy))
                    }

                    HStack(spacing: 12) {
                        rewardLabel(image: event.currencyImageName, value: event.rewards.eventCurrency)
                        rewardLabel(image: "icon_pixel_coin", value: event.rewards.coins)
                        rewardLabel(image: "icon_pixel_crystal", value: event.rewards.crystals)
                    }

                    HStack {
                        Text("\(event.currencyName): \(eventCurrency)")
                            .font(.system(size: 12, weight: .bold))

                        Spacer()

                        Text("HP \(event.hp)")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundStyle(.white.opacity(0.78))
                }
                .foregroundStyle(.white)
                .padding(12)
            }
            .frame(height: 150)
            .opacity(remainingRuns > 0 ? 1 : 0.45)
        }
        .buttonStyle(.plain)
        .disabled(remainingRuns == 0)
    }

    private func rewardLabel(image: String, value: Int) -> some View {
        HStack(spacing: 5) {
            Image(image)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(width: 20, height: 20)

            Text("+\(value)")
                .font(.system(size: 12, weight: .heavy))
        }
    }
}

#Preview {
    EventView(progress: GameProgressStore())
}
