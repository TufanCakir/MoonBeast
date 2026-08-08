//
//  SpriteAnimationScene.swift
//  SpriteSheet
//
//  Created by Tufan Cakir on 29.07.26.
//

import SpriteKit

final class SpriteAnimationScene: SKScene {

    private let arena: ArenaConfiguration
    private let spriteSheets: [SpriteSheet]
    private var characters: [CharacterInstance] = []
    private var unlockedSpriteCount = 1
    private let ground = SKNode()
    private let gridColumns = 5
    private let gridCellWidthRatio: CGFloat = 0.15
    private let gridCellHeightRatio: CGFloat = 0.18
    private let gridCenterXRatio: CGFloat = 0.5
    private let gridRowOffsetRatio: CGFloat = 0.065
    private let gridBaseYRatio: CGFloat = 0.30

    private var floorHeight: CGFloat {
        size.height * arena.floorHeightRatio
    }

    private var gridBaseY: CGFloat {
        floorHeight * gridBaseYRatio
    }

    var availableSpriteCount: Int {
        spriteSheets.count
    }

    init(size: CGSize, arena: ArenaConfiguration) {
        self.arena = arena
        self.spriteSheets = (try? SpriteSheet.loadAll()) ?? []
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)

        if ground.parent == nil { addChild(ground) }
        setupCharactersIfNeeded()

        layoutCharacters()
        setupGround()
    }

    func updateUnlockedSpriteCount(_ count: Int) {
        unlockedSpriteCount = min(max(count, 1), max(spriteSheets.count, 1))
        updateCharacterVisibility()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        layoutCharacters()
        setupGround()
    }

    override func didSimulatePhysics() {
        updateShadowPositions()
    }

    private func setupCharactersIfNeeded() {
        guard characters.isEmpty else { return }

        let sheets = spriteSheets.isEmpty ? [try? SpriteSheet.load()].compactMap { $0 } : spriteSheets

        characters = sheets.enumerated().map { index, sheet in
            let animation = SpriteSheetAnimation(config: sheet)
            let node = SKSpriteNode(texture: animation.firstTexture)
            node.anchorPoint = CGPoint(x: 0.5, y: 0)
            node.zPosition = 2

            let shadow = makeShadow()
            shadow.zPosition = 1
            shadow.isHidden = index >= unlockedSpriteCount

            node.isHidden = index >= unlockedSpriteCount
            addChild(shadow)
            addChild(node)
            animation.start(on: node)

            return CharacterInstance(
                index: index,
                config: sheet,
                animation: animation,
                node: node,
                shadow: shadow
            )
        }
    }

    private func layoutCharacters() {
        for index in characters.indices {
            let character = characters[index]
            let scale = character.config.scale ?? arena.characterScale
            let xPosition = character.config.xPosition
                ?? defaultXPosition(for: character.index, count: characters.count)
            let yOffset = character.config.yOffset ?? 0

            character.node.size = character.animation.size(
                fitting: size,
                scale: scale
            )
            let position = characterPosition(
                for: character.config,
                index: character.index,
                fallbackXPosition: xPosition,
                fallbackYOffset: yOffset
            )
            let yPosition = position.y
            character.node.position = position
            character.node.zPosition = zPosition(for: yPosition)
            character.node.physicsBody = SKPhysicsBody(
                rectangleOf: character.node.size,
                center: CGPoint(x: 0, y: character.node.size.height / 2)
            )
            character.node.physicsBody?.isDynamic = false
            character.node.physicsBody?.allowsRotation = false
            character.node.physicsBody?.friction = 0.8
            character.node.physicsBody?.restitution = 0.1
        }

        updateShadowPositions()
        updateCharacterVisibility()
    }

    private func updateCharacterVisibility() {
        for character in characters {
            let isUnlocked = character.index < unlockedSpriteCount
            character.node.isHidden = !isUnlocked
            character.shadow.isHidden = !isUnlocked
        }
    }

    private func defaultXPosition(for index: Int, count: Int) -> CGFloat {
        guard count > 1 else { return arena.characterXPosition }

        let spacing: CGFloat = 0.18
        let centerOffset = CGFloat(index) - CGFloat(count - 1) * 0.5
        return min(max(arena.characterXPosition + centerOffset * spacing, 0.12), 0.88)
    }

    private func updateShadowPositions() {
        for character in characters {
            let xPosition = character.config.xPosition
                ?? defaultXPosition(
                    for: character.index,
                    count: characters.count
                )
            let position = characterPosition(
                for: character.config,
                index: character.index,
                fallbackXPosition: xPosition,
                fallbackYOffset: character.config.yOffset ?? 0
            )
            character.shadow.position = CGPoint(
                x: position.x,
                y: position.y + 2
            )
            character.shadow.xScale = max(character.node.size.width / 120, 0.18)
            character.shadow.yScale = max(character.node.size.width / 160, 0.14)
            character.shadow.zPosition = character.node.zPosition - 1
        }
    }

    private func characterPosition(
        for config: SpriteSheet,
        index: Int,
        fallbackXPosition: CGFloat,
        fallbackYOffset: CGFloat
    ) -> CGPoint {
        guard let gridColumn = config.gridColumn ?? automaticGridColumn(for: index),
            let gridRow = config.gridRow ?? automaticGridRow(for: index)
        else {
            return CGPoint(
                x: size.width * min(max(fallbackXPosition, 0), 1),
                y: gridBaseY + fallbackYOffset
            )
        }

        let clampedColumn = min(max(gridColumn, 0), gridColumns - 1)
        let clampedRow = max(gridRow, 0)
        let centerColumn = CGFloat(gridColumns - 1) * 0.5
        let columnOffset = CGFloat(clampedColumn) - centerColumn
        let rowOffset = CGFloat(clampedRow)
        let x = size.width * gridCenterXRatio
            + columnOffset * size.width * gridCellWidthRatio
            + alternatingRowOffset(for: clampedRow)
        let y = gridBaseY + rowOffset * floorHeight * gridCellHeightRatio

        return CGPoint(x: x, y: y)
    }

    private func alternatingRowOffset(for row: Int) -> CGFloat {
        row.isMultiple(of: 2) ? 0 : size.width * gridRowOffsetRatio
    }

    private func automaticGridColumn(for index: Int) -> Int? {
        index % gridColumns
    }

    private func automaticGridRow(for index: Int) -> Int? {
        index / gridColumns
    }

    private func zPosition(for yPosition: CGFloat) -> CGFloat {
        1_000 - yPosition
    }

    private func setupGround() {
        ground.physicsBody = SKPhysicsBody(
            edgeFrom: CGPoint(x: 0, y: gridBaseY),
            to: CGPoint(x: size.width, y: gridBaseY)
        )
        ground.physicsBody?.isDynamic = false
    }

    private func makeShadow() -> SKShapeNode {
        let shadow = SKShapeNode()
        let path = CGMutablePath()
        path.addEllipse(in: CGRect(x: -55, y: -8, width: 110, height: 16))
        shadow.path = path
        shadow.fillColor = .black.withAlphaComponent(0.32)
        shadow.strokeColor = .clear
        return shadow
    }

    private struct CharacterInstance {
        let index: Int
        let config: SpriteSheet
        let animation: SpriteSheetAnimation
        let node: SKSpriteNode
        let shadow: SKShapeNode
    }
}
