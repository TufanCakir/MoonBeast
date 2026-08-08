//
//  GameView.swift
//  Project Pixel
//
//  Created by Tufan Cakir on 07.08.26.
//

import SwiftUI
import SpriteKit

struct GameView: View {

    let progress: GameProgressStore
    let onExit: (() -> Void)?

    private let arena: ArenaConfiguration
    
    @State private var scene: SpriteAnimationScene
    @State private var selectedLookIndex = 0
    @State private var isAnimationEnabled: Bool

    private let startDate = Date()
    private let animationFrameInterval = 1.0 / 30.0

    init(
        progress: GameProgressStore,
        arena: ArenaConfiguration = try! ArenaConfiguration.load(),
        onExit: (() -> Void)? = nil
    ) {
        self.progress = progress
        self.onExit = onExit
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

                groundLayer(
                    look: look,
                    viewSize: viewSize,
                    groundHeight: groundHeight
                )

                SpriteView(scene: scene, options: [.allowsTransparency])

                headerHUD
                    .padding(.horizontal)
                    .padding(.top, 54)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .top
                    )

                exitButton
                    .padding(.leading, 14)
                    .padding(.top, 48)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .topLeading
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
        .background(arena.looks[selectedLookIndex].backgroundColor.swiftUIColor)
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
        guard !arena.looks.isEmpty else { return 0 }
        return (stage / 10) % arena.looks.count
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
                    isAnimationEnabled && look.isAnimated
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

    private var headerHUD: some View {
        VStack(spacing: 14) {
            ZStack {
                Text("Stage \(progress.stage)")
                    .font(.system(size: 20, weight: .bold))
                    .padding()
                    .padding(.horizontal)
                    .foregroundStyle(.white)

                resourceLabel(image: "sprite_cookieman", value: progress.ownedSprites.count)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 8) {
                    resourceLabel(image: "icon_pixel_coin", value: progress.coins)
                    resourceLabel(image: "icon_pixel_crystal", value: progress.crystals)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }

            stageHealthBar
                .padding(.horizontal, 52)
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
            .font(.system(size: 11, weight: .heavy))
            .foregroundStyle(.white.opacity(0.82))
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
            .disabled(progress.pendingCoins == 0 && progress.pendingCrystals == 0)
            .padding(.leading, 100)

            Button {
                progress.isAutoBattleEnabled.toggle()
            } label: {
                Text(progress.isAutoBattleEnabled ? "Auto Battle: ON" : "Auto Battle: OFF")
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
                .font(.custom("Asteroid Blaster", size: 18))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .foregroundStyle(.white)
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
