//
//  SummonView.swift
//  Moon Beast
//
//  Created by Tufan Cakir on 07.08.26.
//

import SwiftUI

struct SummonView: View {
    let progress: GameProgressStore

    private let configuration: SummonConfiguration
    private let artifactConfiguration: ArtifactConfiguration

    @State private var selectedPage = 0
    @State private var ratesOverlay: RatesOverlay?
    @State private var pendingSummon: PendingSummon?
    @State private var message = ""

    init(
        progress: GameProgressStore,
        configuration: SummonConfiguration = try! SummonConfiguration.load(),
        artifactConfiguration: ArtifactConfiguration =
            try! ArtifactConfiguration.load()
    ) {
        self.progress = progress
        self.configuration = configuration
        self.artifactConfiguration = artifactConfiguration
    }

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                GameHeader(progress: progress)

                TabView(selection: $selectedPage) {
                    ForEach(
                        Array(configuration.banners.enumerated()),
                        id: \.element.id
                    ) { index, banner in
                        unitBannerPage(banner)
                            .tag(index)
                    }

                    artifactBannerPage(artifactConfiguration.banner)
                        .tag(configuration.banners.count)
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))

                resultList
                    .frame(maxHeight: 190)
            }

            if let ratesOverlay {
                ratesOverlayView(ratesOverlay)
            }

            if let pendingSummon {
                confirmOverlay(pendingSummon)
            }

            if !message.isEmpty {
                messageOverlay
            }
        }
    }

    private func unitBannerPage(_ banner: SummonBanner) -> some View {
        bannerCard(
            title: banner.title,
            imageName: banner.bannerImageName,
            currencyImageName: "icon_pixel_crystal",
            currencyAmount: progress.crystals,
            singleCost: banner.singleCost,
            multiCost: banner.multiCost,
            infoAction: { ratesOverlay = .units(banner) },
            singleAction: { pendingSummon = .unitSingle(banner) },
            multiAction: { pendingSummon = .unitMulti(banner) }
        )
    }

    private func artifactBannerPage(_ banner: ArtifactBanner) -> some View {
        bannerCard(
            title: banner.title,
            imageName: banner.bannerImageName,
            currencyImageName: "icon_pixel_box",
            currencyAmount: progress.artifactShards,
            singleCost: banner.singleCost,
            multiCost: banner.multiCost,
            infoAction: { ratesOverlay = .artifacts(banner) },
            singleAction: { pendingSummon = .artifactSingle(banner) },
            multiAction: { pendingSummon = .artifactMulti(banner) }
        )
    }

    private func bannerCard(
        title: String,
        imageName: String,
        currencyImageName: String,
        currencyAmount: Int,
        singleCost: Int,
        multiCost: Int,
        infoAction: @escaping () -> Void,
        singleAction: @escaping () -> Void,
        multiAction: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 50) {
            HStack {

                Spacer()

                Button(action: infoAction) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)
                        .shadow(
                            color: .black.opacity(0.9),
                            radius: 3,
                            x: 0,
                            y: 2
                        )
                }
                .buttonStyle(.plain)
            }

            Image(imageName)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(height: 118)
                .shadow(color: .black.opacity(0.9), radius: 3, x: 0, y: 2)

            Text(title)
                .font(.system(size: 26, weight: .heavy))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.9), radius: 3, x: 0, y: 2)

            HStack(spacing: 10) {
                summonButton(
                    title: "Single",
                    cost: singleCost,
                    imageName: currencyImageName,
                    action: singleAction
                )
                summonButton(
                    title: "Multi",
                    cost: multiCost,
                    imageName: currencyImageName,
                    action: multiAction
                )
            }
        }
        .padding()
    }

    private func summonButton(
        title: String,
        cost: Int,
        imageName: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 14, weight: .heavy))

                Image(imageName)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 16, height: 16)

                Text("\(cost)")
                    .font(.system(size: 13, weight: .heavy))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background {
                Image("icon_pixel_menü")
                    .resizable()
                    .interpolation(.none)
                    .scaledToFill()
            }
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.9), radius: 3, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    private var resultList: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(progress.lastSummonResults) { result in
                    resultRow(
                        imageName: result.entry.imageName,
                        name: result.entry.name,
                        detail: result.isDuplicate
                            ? "Duplicate  Star \(result.stars)" : "New  Star 1",
                        rarity: result.entry.rarity
                    )
                }

                ForEach(progress.lastArtifactSummonResults) { result in
                    resultRow(
                        imageName: result.entry.imageName,
                        name: result.entry.name,
                        detail: result.isDuplicate
                            ? "Duplicate  Lv \(result.level)" : "New  Lv 1",
                        rarity: result.entry.rarity
                    )
                }
            }
        }
    }

    private func resultRow(
        imageName: String,
        name: String,
        detail: String,
        rarity: SpriteRarity
    ) -> some View {
        HStack(spacing: 10) {
            Image(imageName)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(width: 38, height: 38)

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 14, weight: .heavy))

                Text(detail)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white.opacity(0.75))
            }

            Spacer()

            Text(rarity.title)
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(rarity.color)
        }
        .foregroundStyle(.white)
        .padding(8)
        .background(.black.opacity(0.24))
    }

    private func ratesOverlayView(_ overlay: RatesOverlay) -> some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture { ratesOverlay = nil }

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Rates")
                        .font(.system(size: 22, weight: .heavy))

                    Spacer()

                    Button {
                        ratesOverlay = nil
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .heavy))
                    }
                    .buttonStyle(.plain)
                }

                ForEach(overlay.rows) { row in
                    HStack(spacing: 10) {
                        Image(row.imageName)
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(width: 28, height: 28)

                        Text(row.name)
                        Spacer()
                        Text(row.rarity.title)
                            .foregroundStyle(row.rarity.color)
                        Text("\(Int(row.weight))%")
                            .frame(width: 42, alignment: .trailing)
                    }
                    .font(.system(size: 13, weight: .bold))
                }
            }
            .foregroundStyle(.white)
            .padding(18)
            .background(.black.opacity(0.82))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .padding(.horizontal, 26)
        }
    }

    private func confirmOverlay(_ pending: PendingSummon) -> some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("Summon?")
                    .font(.system(size: 24, weight: .heavy))

                AppResourceLabel(
                    imageName: pending.currencyImageName,
                    value: pending.cost,
                    iconSize: 26,
                    fontSize: 16
                )

                HStack(spacing: 12) {
                    Button("Cancel") {
                        pendingSummon = nil
                    }
                    .buttonStyle(.bordered)

                    Button("Confirm") {
                        runSummon(pending)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .foregroundStyle(.white)
            .padding(22)
            .background(.black.opacity(0.82))
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }

    private var messageOverlay: some View {
        VStack {
            Spacer()

            Text(message)
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(.black.opacity(0.78))
                .clipShape(Capsule())
                .padding(.bottom, 132)
        }
    }

    private func runSummon(_ pending: PendingSummon) {
        let didSummon: Bool

        switch pending {
        case .unitSingle(let banner):
            didSummon = progress.summonSingle(from: banner)
        case .unitMulti(let banner):
            didSummon = progress.summonMulti(from: banner)
        case .artifactSingle(let banner):
            didSummon = progress.summonArtifactSingle(from: banner)
        case .artifactMulti(let banner):
            didSummon = progress.summonArtifactMulti(from: banner)
        }

        pendingSummon = nil
        message = didSummon ? "" : "Not enough \(pending.currencyName)"
    }
}

private enum PendingSummon {
    case unitSingle(SummonBanner)
    case unitMulti(SummonBanner)
    case artifactSingle(ArtifactBanner)
    case artifactMulti(ArtifactBanner)

    var cost: Int {
        switch self {
        case .unitSingle(let banner):
            banner.singleCost
        case .artifactSingle(let banner):
            banner.singleCost
        case .unitMulti(let banner):
            banner.multiCost
        case .artifactMulti(let banner):
            banner.multiCost
        }
    }

    var currencyImageName: String {
        switch self {
        case .unitSingle, .unitMulti:
            "icon_pixel_crystal"
        case .artifactSingle, .artifactMulti:
            "icon_pixel_box"
        }
    }

    var currencyName: String {
        switch self {
        case .unitSingle, .unitMulti:
            "crystals"
        case .artifactSingle, .artifactMulti:
            "artifact shards"
        }
    }
}

private enum RatesOverlay {
    case units(SummonBanner)
    case artifacts(ArtifactBanner)

    var rows: [RateRow] {
        switch self {
        case .units(let banner):
            banner.entries.map {
                RateRow(
                    id: $0.id,
                    name: $0.name,
                    imageName: $0.imageName,
                    rarity: $0.rarity,
                    weight: $0.weight
                )
            }
        case .artifacts(let banner):
            banner.entries.map {
                RateRow(
                    id: $0.id,
                    name: $0.name,
                    imageName: $0.imageName,
                    rarity: $0.rarity,
                    weight: $0.weight
                )
            }
        }
    }
}

private struct RateRow: Identifiable {
    let id: String
    let name: String
    let imageName: String
    let rarity: SpriteRarity
    let weight: Double
}

#Preview {
    SummonView(progress: GameProgressStore())
}
