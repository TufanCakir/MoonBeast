//
//  EventView.swift
//  Moon Beast
//
//  Created by Tufan Cakir on 08.08.26.
//

import SwiftUI

struct EventView: View {
    let progress: GameProgressStore

    private let configuration: EventConfiguration
    @State private var message = ""

    init(
        progress: GameProgressStore,
        configuration: EventConfiguration = try! EventConfiguration.load()
    ) {
        self.progress = progress
        self.configuration = configuration
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Events")
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundStyle(.white)
                    .padding(.top, 18)

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
        .onAppear {
            progress.refreshDailyEventLimits(for: configuration.events)
        }
        .background {
            AppBackground()
        }
    }

    private func eventBanner(_ event: GameEvent) -> some View {
        let remainingRuns = progress.remainingRuns(for: event)
        let eventCurrency = progress.eventCurrencies[event.id, default: 0]

        return Button {
            let didFight = progress.fightEvent(event)
            message =
                didFight ? "\(event.title) cleared" : "Daily limit reached"
        } label: {
            VStack(spacing: 0) {
                ZStack(alignment: .bottomLeading) {
                    Image(event.bannerImageName)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .clipped()

                    LinearGradient(
                        colors: [.blue.opacity(0.0), .blue.opacity(0.82)],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(event.title)
                                .font(.system(size: 20, weight: .heavy))
                                .lineLimit(1)

                            Spacer()

                            Text("\(remainingRuns)/\(event.dailyLimit)")
                                .font(.system(size: 13, weight: .heavy))
                        }

                        HStack(spacing: 12) {
                            AppResourceLabel(
                                imageName: event.currencyImageName,
                                value: event.rewards.eventCurrency,
                                prefix: "+",
                                iconSize: 20,
                                fontSize: 12
                            )
                            AppResourceLabel(
                                imageName: "icon_pixel_coin",
                                value: event.rewards.coins,
                                prefix: "+",
                                iconSize: 20,
                                fontSize: 12
                            )
                            AppResourceLabel(
                                imageName: "icon_pixel_crystal",
                                value: event.rewards.crystals,
                                prefix: "+",
                                iconSize: 20,
                                fontSize: 12
                            )
                        }

                        HStack {
                            Text("\(event.currencyName): \(eventCurrency)")
                                .font(.system(size: 12, weight: .bold))
                                .lineLimit(1)

                            Spacer()

                            Text("HP \(event.hp)")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundStyle(.white.opacity(0.78))
                    }
                    .foregroundStyle(.white)
                    .padding(12)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .contentShape(RoundedRectangle(cornerRadius: 8))
            .opacity(remainingRuns > 0 ? 1 : 0.45)
        }
        .buttonStyle(.plain)
        .disabled(remainingRuns == 0)
    }
}

#Preview {
    EventView(progress: GameProgressStore())
}
