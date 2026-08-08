//
//  SummonView.swift
//  Project Pixel
//
//  Created by Tufan Cakir on 07.08.26.
//

import SwiftUI

struct SummonView: View {
    let progress: GameProgressStore

    private let configuration: SummonConfiguration
    @State private var selectedBannerIndex = 0
    @State private var message = ""

    init(
        progress: GameProgressStore,
        configuration: SummonConfiguration = try! SummonConfiguration.load()
    ) {
        self.progress = progress
        self.configuration = configuration
    }

    var body: some View {
        ZStack {
            AppBackground()

            if let banner = selectedBanner {
                ScrollView {
                    VStack(spacing: 18) {
                        bannerHeader(banner)
                        summonActions(banner)
                        resultList
                        rateList(banner)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 64)
                    .padding(.bottom, 110)
                }
            }
        }
    }

    private var selectedBanner: SummonBanner? {
        guard configuration.banners.indices.contains(selectedBannerIndex) else {
            return nil
        }

        return configuration.banners[selectedBannerIndex]
    }

    private func bannerHeader(_ banner: SummonBanner) -> some View {
        VStack(spacing: 14) {
            Image(banner.bannerImageName)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(maxWidth: 280)

            HStack {
                resourceLabel(image: "icon_pixel_crystal", value: progress.crystals)

                Spacer()

                Text("\(progress.ownedSprites.count) Units")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(.white.opacity(0.85))
            }

            Text(banner.title)
                .font(.custom("Asteroid Blaster", size: 28))
                .foregroundStyle(.white)
        }
    }

    private func summonActions(_ banner: SummonBanner) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                summonButton(
                    title: "Single",
                    cost: banner.singleCost,
                    isEnabled: progress.crystals >= banner.singleCost
                ) {
                    runSummon(progress.summonSingle(from: banner))
                }

                summonButton(
                    title: "Multi",
                    cost: banner.multiCost,
                    isEnabled: progress.crystals >= banner.multiCost
                ) {
                    runSummon(progress.summonMulti(from: banner))
                }
            }

            if !message.isEmpty {
                Text(message)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white.opacity(0.82))
            }
        }
    }

    private func summonButton(
        title: String,
        cost: Int,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 15, weight: .heavy))

                Image("icon_pixel_crystal")
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 18, height: 18)

                Text("\(cost)")
                    .font(.system(size: 14, weight: .heavy))
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(isEnabled ? .cyan : .gray)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }

    private var resultList: some View {
        VStack(spacing: 10) {
            ForEach(progress.lastSummonResults) { result in
                HStack(spacing: 12) {
                    Image(result.entry.imageName)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 44, height: 44)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(result.entry.name)
                            .font(.system(size: 15, weight: .heavy))

                        Text(result.isDuplicate ? "Duplicate  Star \(result.stars)" : "New  Star 1")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white.opacity(0.7))
                    }

                    Spacer()

                    Text(result.entry.rarity.title)
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(result.entry.rarity.color)
                }
                .foregroundStyle(.white)
                .padding(10)
                .background(.white.opacity(0.08))
            }
        }
    }

    private func rateList(_ banner: SummonBanner) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Rates")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(.white)

            ForEach(banner.entries) { entry in
                HStack(spacing: 10) {
                    Image(entry.imageName)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 28, height: 28)

                    Text(entry.name)
                        .font(.system(size: 13, weight: .bold))

                    Spacer()

                    Text(entry.rarity.title)
                        .foregroundStyle(entry.rarity.color)

                    Text("\(Int(entry.weight))%")
                        .frame(width: 42, alignment: .trailing)
                }
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(.white.opacity(0.85))
            }
        }
        .padding(12)
        .background(.white.opacity(0.06))
    }

    private func resourceLabel(image: String, value: Int) -> some View {
        HStack(spacing: 8) {
            Image(image)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(width: 28, height: 28)

            Text("\(value)")
                .font(.custom("Asteroid Blaster", size: 18))
                .foregroundStyle(.white)
        }
    }

    private func runSummon(_ didSummon: Bool) {
        message = didSummon ? "" : "Not enough crystals"
    }
}

#Preview {
    SummonView(progress: GameProgressStore())
}
