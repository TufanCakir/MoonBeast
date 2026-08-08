//
//  GameView.swift
//  Moon Beast
//
//  Created by Tufan Cakir on 07.08.26.
//

import SwiftUI
import SpriteKit

struct GameView: View {

    let progress: GameProgressStore
    let onExit: (() -> Void)?

    private let arena: ArenaConfiguration
    private let background: BackgroundConfiguration
    
    @State private var scene: SpriteAnimationScene
    @State private var selectedLookIndex = 0
    @State private var isLayerAnimationEnabled = true

    private let startDate = Date()
    private let animationFrameInterval = 1.0 / 30.0

    init(
        progress: GameProgressStore,
        arena: ArenaConfiguration = try! ArenaConfiguration.load(),
        background: BackgroundConfiguration = try! BackgroundConfiguration.load(),
        onExit: (() -> Void)? = nil
    ) {
        self.progress = progress
        self.onExit = onExit
        self.arena = arena
        self.background = background
        _scene = State(
            initialValue: SpriteAnimationScene.makeDefaultScene(arena: arena)
        )
    }

    var body: some View {
        GeometryReader { proxy in
            let viewSize = proxy.size
            let groundHeight = viewSize.height * arena.floorHeightRatio
            let backgroundLook = background.looks[backgroundLookIndex]
            let groundLook = arena.looks[groundLookIndex]

            ZStack(alignment: .bottom) {
                backgroundLayer(look: backgroundLook, viewSize: viewSize)
                backgroundDarkeningLayer(look: backgroundLook)

                groundLayer(
                    look: groundLook,
                    viewSize: viewSize,
                    groundHeight: groundHeight
                )
                groundDarkeningLayer(look: groundLook, groundHeight: groundHeight)

                SpriteView(scene: scene, options: [.allowsTransparency])

                headerHUD
                    .padding(.horizontal)
                    .padding(.top, 54)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .top
                    )

                stageTitle
                    .padding(.top, 150)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .top
                    )

                exitButton
                    .padding(.horizontal)
                    .padding(.top, 110)
                    .padding(.leading, 330)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .top
                    )

                claimPanel
                    .padding(.horizontal)
                    .padding(.top, 200)
                    .padding(.leading, 200)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .top
                    )
            }
            .frame(width: viewSize.width, height: viewSize.height)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(background.looks[backgroundLookIndex].backgroundColor.swiftUIColor)
        .ignoresSafeArea()
        .onTapGesture {
            attackStage()
        }
        .onAppear {
            selectedLookIndex = lookIndex(for: progress.stage)
            scene.updateUnlockedSpriteIndices(progress.unlockedSpriteIndices)
        }
        .onChange(of: progress.stage) { _, stage in
            selectedLookIndex = lookIndex(for: stage)
        }
        .onChange(of: progress.unlockedSpriteIndices) { _, indices in
            scene.updateUnlockedSpriteIndices(indices)
        }
        .task {
            await runAutoBattleLoop()
        }
    }
    
    private func runAutoBattleLoop() async {
        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(1.4))
            
            guard progress.isAutoBattleEnabled else { continue }
            
            await MainActor.run {
                attackStage()
            }
        }
    }

    private func attackStage() {
        progress.attackStage()
    }
    
    private func claimRewards() {
        progress.claimRewards()
    }

    private func lookIndex(for stage: Int) -> Int {
        let availableLookCount = min(background.looks.count, arena.looks.count)
        guard availableLookCount > 0 else { return 0 }
        return (stage / 10) % availableLookCount
    }

    private var backgroundLookIndex: Int {
        guard !background.looks.isEmpty else { return 0 }
        return min(selectedLookIndex, background.looks.count - 1)
    }

    private var groundLookIndex: Int {
        guard !arena.looks.isEmpty else { return 0 }
        return min(selectedLookIndex, arena.looks.count - 1)
    }

    @ViewBuilder
    private func backgroundLayer(
        look: GameBackgroundLook,
        viewSize: CGSize
    ) -> some View {
        if let backgroundImageName = look.backgroundImageName {
            Image(backgroundImageName)
                .resizable()
                .interpolation(.none)
                .scaledToFill()
                .frame(width: viewSize.width, height: viewSize.height)
                .clipped()
                .ignoresSafeArea()
        } else {
            TimelineView(.periodic(from: startDate, by: animationFrameInterval)) { timeline in
                let time =
                    isLayerAnimationEnabled && look.isAnimated
                    ? Float(timeline.date.timeIntervalSince(startDate))
                        * Float(look.animationSpeed)
                    : 0

                Rectangle()
                    .fill(
                        ShaderLibrary.staticArenaBackground(
                            .float2(
                                Float(viewSize.width),
                                Float(viewSize.height)
                            ),
                            .float(time),
                            .float(Float(look.glowIntensity)),
                            .float(Float(look.accentColor.red)),
                            .float(Float(look.accentColor.green)),
                            .float(Float(look.accentColor.blue))
                        )
                    )
                    .ignoresSafeArea()
            }
        }
    }

    @ViewBuilder
    private func backgroundDarkeningLayer(look: GameBackgroundLook) -> some View {
        let opacity = min(max(look.backgroundDarkening, 0), 1)

        if opacity > 0 {
            Color.black
                .opacity(opacity)
                .ignoresSafeArea()
        }
    }

    @ViewBuilder
    private func groundLayer(
        look: ArenaLook,
        viewSize: CGSize,
        groundHeight: CGFloat
    ) -> some View {
        if let groundImageName = look.groundImageName {
            Image(groundImageName)
                .resizable()
                .interpolation(.none)
                .scaledToFill()
                .frame(width: viewSize.width, height: groundHeight)
                .clipped()
        } else {
            TimelineView(.periodic(from: startDate, by: animationFrameInterval)) { timeline in
                let time =
                    isLayerAnimationEnabled && look.isAnimated
                    ? Float(timeline.date.timeIntervalSince(startDate))
                    : 0

                Rectangle()
                    .fill(
                        ShaderLibrary.riverFloor(
                            .float2(
                                Float(viewSize.width),
                                Float(groundHeight)
                            ),
                            .float(time),
                            .float(Float(look.animationSpeed)),
                            .float(Float(look.glowIntensity)),
                            .float(Float(look.gridIntensity)),
                            .float(Float(look.scanlineIntensity)),
                            .float(Float(look.accentColor.red)),
                            .float(Float(look.accentColor.green)),
                            .float(Float(look.accentColor.blue))
                        )
                    )
                    .frame(height: groundHeight)
            }
        }
    }

    @ViewBuilder
    private func groundDarkeningLayer(
        look: ArenaLook,
        groundHeight: CGFloat
    ) -> some View {
        let opacity = min(max(look.groundDarkening, 0), 1)

        if opacity > 0 {
            Rectangle()
                .fill(.black.opacity(opacity))
                .frame(height: groundHeight)
        }
    }

    private var headerHUD: some View {
        VStack(spacing: 20) {
            GameHeader(progress: progress)

            stageHealthBar
                .padding(.horizontal, 50)
                .shadow(color: .black.opacity(0.9), radius: 3, x: 0, y: 2)
        }
    }

    private var stageTitle: some View {
        Text("Stage \(progress.stage)")
            .font(.system(size: 30, weight: .bold))
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.9), radius: 3, x: 0, y: 2)
    }

    private var exitButton: some View {
        Button {
            onExit?()
        } label: {
            Image(systemName: "rectangle.portrait.and.arrow.right")
                .font(.system(size: 20, weight: .heavy))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.9), radius: 3, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    private var stageHealthBar: some View {
        VStack(spacing: 5) {
            GeometryReader { proxy in
                let ratio = CGFloat(progress.stageHP) / CGFloat(max(progress.maxStageHP, 1))

                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(.black.opacity(0.58))

                    Rectangle()
                        .fill(.red)
                        .frame(width: proxy.size.width * min(max(ratio, 0), 1))
                }
            }
            .frame(height: 14)
            .overlay {
                Rectangle()
                    .stroke(.white.opacity(0.55), lineWidth: 1)
            }

            HStack {
                Text("Raid HP")
                Spacer()
                Text("\(progress.stageHP)/\(progress.maxStageHP)")
            }
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.9), radius: 3, x: 0, y: 2)
        }
    }
    
    private var box: some View {
            Image("icon_pixel_box")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
        }
        
    private var claimPanel: some View {
        VStack(spacing: 30) {
            if progress.hasPendingRewards {
                HStack(spacing: 10) {
                    AppResourceLabel(
                        imageName: "icon_pixel_coin",
                        value: progress.pendingCoins,
                        prefix: "+",
                        iconSize: 22,
                        fontSize: 12
                    )

                    AppResourceLabel(
                        imageName: "icon_pixel_crystal",
                        value: progress.pendingCrystals,
                        prefix: "+",
                        iconSize: 22,
                        fontSize: 12
                    )
                }
            }

            Button {
                claimRewards()
            } label: {
                Text("Claim")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .background(
                      box
                    )
            }
            .disabled(!progress.hasPendingRewards)
            .padding(.leading, 100)

            Button {
                progress.isAutoBattleEnabled.toggle()
            } label: {
                Text(progress.isAutoBattleEnabled ? "Auto Battle: ON" : "Auto Battle: OFF")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.leading, 100)
            }

            Button {
                isLayerAnimationEnabled.toggle()
            } label: {
                Text(isLayerAnimationEnabled ? "Layer Animation: ON" : "Layer Animation: OFF")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.leading, 100)
            }

            if progress.canPrestige {
                Button {
                    progress.prestige()
                } label: {
                    Text("Prestige +\(max(progress.stage / 10, 1)) Shards")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.yellow)
                        .padding(.leading, 100)
                }
            }
        }
    }

}

extension SpriteAnimationScene {
    fileprivate static func makeDefaultScene(arena: ArenaConfiguration)
        -> SpriteAnimationScene
    {
        let scene = SpriteAnimationScene(
            size: CGSize(width: 400, height: 400),
            arena: arena
        )
        scene.scaleMode = .resizeFill
        scene.backgroundColor = .clear
        return scene
    }
}

#Preview {
    GameView(progress: GameProgressStore())
}
