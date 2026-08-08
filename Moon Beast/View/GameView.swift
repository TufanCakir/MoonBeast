//
//  GameView.swift
//  Project Pixel
//
//  Created by Tufan Cakir on 07.08.26.
//

import SwiftUI
import SpriteKit

struct GameView: View {

    private let arena: ArenaConfiguration
    
    @State private var stage = 0
    @State private var coins = 0
    @State private var crystals = 0
    @State private var pendingCoins = 0
    @State private var pendingCrystals = 0
    @State private var unlockedSpriteCount = 1
    @State private var scene: SpriteAnimationScene
    @State private var selectedLookIndex = 0
    @State private var isAnimationEnabled: Bool
    @State private var isAutoBattleEnabled = true

    private let startDate = Date()

    init(arena: ArenaConfiguration = try! ArenaConfiguration.load()) {
        self.arena = arena
        _scene = State(
            initialValue: SpriteAnimationScene.makeDefaultScene(arena: arena)
        )
        _isAnimationEnabled = State(initialValue: arena.isAnimated)
    }

    var body: some View {
        GeometryReader { proxy in
            let viewSize = proxy.size
            let groundHeight = viewSize.height * arena.floorHeightRatio
            let look = arena.looks[selectedLookIndex]

            TimelineView(.animation) { timeline in
                let time =
                    isAnimationEnabled && look.isAnimated
                    ? Float(timeline.date.timeIntervalSince(startDate))
                    : 0

                ZStack(alignment: .bottom) {
                    Rectangle()
                        .fill(
                            ShaderLibrary.staticArenaBackground(
                                .float2(
                                    Float(viewSize.width),
                                    Float(viewSize.height)
                                ),
                                .float(Float(look.glowIntensity)),
                                .float(Float(look.accentColor.red)),
                                .float(Float(look.accentColor.green)),
                                .float(Float(look.accentColor.blue))
                            )
                        )
                        .ignoresSafeArea()

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
                    
                  

                    SpriteView(scene: scene, options: [.allowsTransparency])
                    
                    
                    headerHUD
                        .padding(.horizontal)
                        .padding(.top, 54)
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
        }
        .background(arena.looks[selectedLookIndex].backgroundColor.swiftUIColor)
        .ignoresSafeArea()
        .onTapGesture {
            advanceStage()
        }
        .task {
            await runAutoBattleLoop()
        }
    }
    
    private func runAutoBattleLoop() async {
        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(1.4))
            
            guard isAutoBattleEnabled else { continue }
            
            await MainActor.run {
                advanceStage()
            }
        }
    }

    private func advanceStage() {
        let nextStage = stage + 1
        stage = nextStage
        selectedLookIndex = lookIndex(for: nextStage)
        collectRewards(for: nextStage)
        updateUnlockedSprites(for: nextStage)
    }

    private func collectRewards(for stage: Int) {
        pendingCoins += 25 + stage * 3

        if stage.isMultiple(of: 10) {
            pendingCrystals += 1 + stage / 50
        }
    }
    
    private func claimRewards() {
        coins += pendingCoins
        crystals += pendingCrystals
        pendingCoins = 0
        pendingCrystals = 0
    }

    private func lookIndex(for stage: Int) -> Int {
        guard !arena.looks.isEmpty else { return 0 }
        return (stage / 10) % arena.looks.count
    }

    private func updateUnlockedSprites(for stage: Int) {
        let nextUnlockedCount = 1 + stage / 10
        unlockedSpriteCount = min(nextUnlockedCount, max(scene.availableSpriteCount, 1))
        scene.updateUnlockedSpriteCount(unlockedSpriteCount)
    }

    private var headerHUD: some View {
        ZStack {
            Text("Stage \(stage)")
                .font(.system(size: 20, weight: .heavy))
                .foregroundStyle(.white)
                .padding(.horizontal)
                .offset(y: 80)

            resourceLabel(image: "sprite_cookieman", value: unlockedSpriteCount)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 8) {
                resourceLabel(image: "icon_pixel_coin", value: coins)
                resourceLabel(image: "icon_pixel_crystal", value: crystals)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
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

            Button {
                claimRewards()
            } label: {
                Text("Claim")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(.white)
                    .background(
                      box
                    )
            }
            .disabled(pendingCoins == 0 && pendingCrystals == 0)
            .padding(.leading, 100)

            Button {
                isAutoBattleEnabled.toggle()
            } label: {
                Text(isAutoBattleEnabled ? "Auto Battle: ON" : "Auto Battle: OFF")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.leading, 100)
            }
        }
    }

    private func resourceLabel(
        image: String,
        value: Int
    ) -> some View {
        HStack(spacing: 10) {
            Image(image)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(width: 32, height: 32)
            
            Text("\(value)")
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .font(.system(size: 18, weight: .heavy))
        .foregroundStyle(.white)
    }
}



typealias SpritesheetView = GameView

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
    GameView()
}
