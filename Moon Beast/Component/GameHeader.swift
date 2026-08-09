//
//  GameHeader.swift
//  Moon Beast
//
//  Created by Tufan Cakir on 08.08.26.
//

import SwiftUI

struct GameHeader: View {
    let progress: GameProgressStore

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 8) {
                Text("LV \(progress.accountLevel)")
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.9), radius: 3, x: 0, y: 2)

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(.black.opacity(0.28))

                        Capsule()
                            .fill(.white.opacity(0.48))
                            .frame(
                                width: proxy.size.width
                                    * min(max(progress.accountXPProgress, 0), 1)
                            )
                    }
                }
                .frame(width: 110, height: 8)
            }

            Spacer()

            AppResourceLabel(
                imageName: "icon_pixel_coin",
                value: progress.coins,
                iconSize: 24,
                fontSize: 13
            )

            AppResourceLabel(
                imageName: "icon_pixel_crystal",
                value: progress.crystals,
                iconSize: 24,
                fontSize: 13
            )

            AppResourceLabel(
                imageName: "icon_pixel_relic",
                value: progress.artifactShards,
                iconSize: 24,
                fontSize: 13
            )
        }
        .padding(.horizontal)
    }
}

#Preview {
    ZStack {
        AppBackground()
        GameHeader(
            progress: GameProgressStore()
        )
    }
}
