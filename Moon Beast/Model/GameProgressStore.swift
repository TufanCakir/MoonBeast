//
//  GameProgressStore.swift
//  Moon Beast
//
//  Created by Tufan Cakir on 08.08.26.
//

import CoreGraphics
import Foundation
import Observation

@Observable
final class GameProgressStore {
    private static let saveKey = "moonBeastGameProgress"

    private(set) var stage = 0
    private(set) var stageHP = 40
    private(set) var maxStageHP = 40
    private(set) var accountLevel = 1
    private(set) var accountXP = 0
    private(set) var accountXPToNextLevel = 100
    private(set) var prestigeCount = 0
    private(set) var artifactShards = 0
    private(set) var coins = 0
    private(set) var crystals = 0
    private(set) var pendingCoins = 0
    private(set) var pendingCrystals = 0
    private(set) var ownedSprites: [Int: OwnedSprite] = [:]
    private(set) var ownedArtifacts: [String: OwnedArtifact] = [:]
    private(set) var lastSummonResults: [SummonResult] = []
    private(set) var lastArtifactSummonResults: [ArtifactSummonResult] = []
    private(set) var eventCurrencies: [String: Int] = [:]
    private(set) var eventRunsByID: [String: EventRunProgress] = [:]

    var isAutoBattleEnabled = true

    init() {
        loadProgress()
        unlockStarterIfNeeded()
        recalculateStageHPIfNeeded()
    }

    var unlockedSpriteIndices: Set<Int> {
        Set(ownedSprites.keys)
    }

    var battlePower: Int {
        let spritePower = ownedSprites.values.reduce(0) {
            $0 + max($1.stars, 1)
        }
        let artifactPower = ownedArtifacts.values.reduce(0) {
            $0 + $1.damageBonus * max($1.level, 1)
        }
        let levelPower = accountLevel * 2
        let prestigePower = prestigeCount * 10
        return max(1, spritePower + artifactPower + levelPower + prestigePower)
    }

    var hasPendingRewards: Bool {
        pendingCoins > 0 || pendingCrystals > 0
    }

    var stageHPProgress: CGFloat {
        CGFloat(stageHP) / CGFloat(max(maxStageHP, 1))
    }

    var accountXPProgress: CGFloat {
        CGFloat(accountXP) / CGFloat(max(accountXPToNextLevel, 1))
    }

    var canPrestige: Bool {
        stage >= 20
    }

    func attackStage() {
        stageHP = max(stageHP - battlePower, 0)

        if stageHP == 0 {
            advanceStage()
        } else {
            saveProgress()
        }
    }

    private func advanceStage() {
        let nextStage = stage + 1
        stage = nextStage
        maxStageHP = Self.maxHP(for: nextStage)
        stageHP = maxStageHP
        pendingCoins += 25 + nextStage * 3
        addAccountXP(12 + nextStage * 2)

        if nextStage.isMultiple(of: 10) {
            pendingCrystals += 1 + nextStage / 50
        }

        saveProgress()
    }

    func remainingRuns(for event: GameEvent) -> Int {
        let usedRuns = eventRunsByID[event.id]?.usedRuns ?? 0
        let resetDay = eventRunsByID[event.id]?.resetDay

        guard resetDay == Self.todayKey() else {
            return event.dailyLimit
        }

        return max(event.dailyLimit - usedRuns, 0)
    }

    func refreshDailyEventLimits(for events: [GameEvent]) {
        for event in events {
            resetEventIfNeeded(eventID: event.id)
        }
    }

    @discardableResult
    func fightEvent(_ event: GameEvent) -> Bool {
        resetEventIfNeeded(eventID: event.id)

        guard remainingRuns(for: event) > 0 else { return false }

        let currentRun =
            eventRunsByID[event.id]
            ?? EventRunProgress(
                eventID: event.id,
                usedRuns: 0,
                resetDay: Self.todayKey()
            )

        eventRunsByID[event.id] = EventRunProgress(
            eventID: event.id,
            usedRuns: currentRun.usedRuns + 1,
            resetDay: Self.todayKey()
        )
        eventCurrencies[event.id, default: 0] += event.rewards.eventCurrency
        coins += event.rewards.coins
        crystals += event.rewards.crystals
        saveProgress()
        return true
    }

    func claimRewards() {
        coins += pendingCoins
        crystals += pendingCrystals
        pendingCoins = 0
        pendingCrystals = 0
        saveProgress()
    }

    func prestige() {
        guard canPrestige else { return }

        let earnedShards = max(1, stage / 10)
        prestigeCount += 1
        artifactShards += earnedShards
        stage = 0
        maxStageHP = Self.maxHP(for: stage)
        stageHP = maxStageHP
        pendingCoins = 0
        pendingCrystals = 0
        saveProgress()
    }

    @discardableResult
    func summonSingle(from banner: SummonBanner) -> Bool {
        summon(count: 1, cost: banner.singleCost, from: banner)
    }

    @discardableResult
    func summonMulti(from banner: SummonBanner) -> Bool {
        summon(count: banner.multiCount, cost: banner.multiCost, from: banner)
    }

    @discardableResult
    func summonArtifactSingle(from banner: ArtifactBanner) -> Bool {
        summonArtifact(count: 1, cost: banner.singleCost, from: banner)
    }

    @discardableResult
    func summonArtifactMulti(from banner: ArtifactBanner) -> Bool {
        summonArtifact(
            count: banner.multiCount,
            cost: banner.multiCost,
            from: banner
        )
    }

    private func summon(count: Int, cost: Int, from banner: SummonBanner)
        -> Bool
    {
        guard crystals >= cost, count > 0 else { return false }

        crystals -= cost
        lastSummonResults = (0..<count).compactMap { _ in
            guard let entry = rollEntry(from: banner.entries) else {
                return nil
            }

            let oldStars = ownedSprites[entry.spriteIndex]?.stars ?? 0
            let newStars = oldStars + 1
            ownedSprites[entry.spriteIndex] = OwnedSprite(
                spriteIndex: entry.spriteIndex,
                name: entry.name,
                imageName: entry.imageName,
                rarity: entry.rarity,
                stars: newStars
            )

            return SummonResult(
                entry: entry,
                isDuplicate: oldStars > 0,
                stars: newStars
            )
        }

        saveProgress()
        return !lastSummonResults.isEmpty
    }

    private func rollEntry(from entries: [SummonEntry]) -> SummonEntry? {
        let totalWeight = entries.reduce(0) { $0 + max($1.weight, 0) }
        guard totalWeight > 0 else { return entries.randomElement() }

        var roll = Double.random(in: 0..<totalWeight)

        for entry in entries {
            roll -= max(entry.weight, 0)

            if roll <= 0 {
                return entry
            }
        }

        return entries.last
    }

    private func summonArtifact(
        count: Int,
        cost: Int,
        from banner: ArtifactBanner
    ) -> Bool {
        guard artifactShards >= cost, count > 0 else { return false }

        artifactShards -= cost
        lastArtifactSummonResults = (0..<count).compactMap { _ in
            guard let entry = rollArtifact(from: banner.entries) else {
                return nil
            }

            let oldLevel = ownedArtifacts[entry.id]?.level ?? 0
            let newLevel = oldLevel + 1
            ownedArtifacts[entry.id] = OwnedArtifact(
                artifactID: entry.id,
                name: entry.name,
                imageName: entry.imageName,
                rarity: entry.rarity,
                damageBonus: entry.damageBonus,
                level: newLevel
            )

            return ArtifactSummonResult(
                entry: entry,
                isDuplicate: oldLevel > 0,
                level: newLevel
            )
        }

        saveProgress()
        return !lastArtifactSummonResults.isEmpty
    }

    private func rollArtifact(from entries: [ArtifactEntry]) -> ArtifactEntry? {
        let totalWeight = entries.reduce(0) { $0 + max($1.weight, 0) }
        guard totalWeight > 0 else { return entries.randomElement() }

        var roll = Double.random(in: 0..<totalWeight)

        for entry in entries {
            roll -= max(entry.weight, 0)

            if roll <= 0 {
                return entry
            }
        }

        return entries.last
    }

    private func addAccountXP(_ amount: Int) {
        accountXP += max(amount, 0)

        while accountXP >= accountXPToNextLevel {
            accountXP -= accountXPToNextLevel
            accountLevel += 1
            accountXPToNextLevel = Self.xpToNextLevel(for: accountLevel)
        }
    }

    private func loadProgress() {
        guard
            let data = UserDefaults.standard.data(forKey: Self.saveKey),
            let snapshot = try? JSONDecoder().decode(
                ProgressSnapshot.self,
                from: data
            )
        else {
            return
        }

        stage = snapshot.stage
        stageHP = snapshot.stageHP
        maxStageHP = snapshot.maxStageHP
        accountLevel = snapshot.accountLevel
        accountXP = snapshot.accountXP
        accountXPToNextLevel = Self.xpToNextLevel(for: accountLevel)
        prestigeCount = snapshot.prestigeCount
        artifactShards = snapshot.artifactShards
        coins = snapshot.coins
        crystals = snapshot.crystals
        pendingCoins = snapshot.pendingCoins
        pendingCrystals = snapshot.pendingCrystals
        eventCurrencies = snapshot.eventCurrencies
        eventRunsByID = snapshot.eventRunsByID
        ownedSprites = Dictionary(
            uniqueKeysWithValues: snapshot.ownedSprites.map {
                ($0.spriteIndex, $0)
            }
        )
        ownedArtifacts = Dictionary(
            uniqueKeysWithValues: snapshot.ownedArtifacts.map {
                ($0.artifactID, $0)
            }
        )
    }

    private func saveProgress() {
        let snapshot = ProgressSnapshot(
            stage: stage,
            stageHP: stageHP,
            maxStageHP: maxStageHP,
            accountLevel: accountLevel,
            accountXP: accountXP,
            prestigeCount: prestigeCount,
            artifactShards: artifactShards,
            coins: coins,
            crystals: crystals,
            pendingCoins: pendingCoins,
            pendingCrystals: pendingCrystals,
            ownedSprites: Array(ownedSprites.values),
            ownedArtifacts: Array(ownedArtifacts.values),
            eventCurrencies: eventCurrencies,
            eventRunsByID: eventRunsByID
        )

        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        UserDefaults.standard.set(data, forKey: Self.saveKey)
    }

    private func unlockStarterIfNeeded() {
        guard ownedSprites[0] == nil else { return }

        ownedSprites[0] = OwnedSprite(
            spriteIndex: 0,
            name: "Cookieman",
            imageName: "sprite_cookieman",
            rarity: .common,
            stars: 1
        )
        saveProgress()
    }

    private func recalculateStageHPIfNeeded() {
        let expectedMaxHP = Self.maxHP(for: stage)

        if maxStageHP <= 0 || maxStageHP != expectedMaxHP {
            maxStageHP = expectedMaxHP
            stageHP = min(max(stageHP, 1), maxStageHP)
            saveProgress()
        }
    }

    private func resetEventIfNeeded(eventID: String) {
        let today = Self.todayKey()

        guard eventRunsByID[eventID]?.resetDay != today else { return }

        eventRunsByID[eventID] = EventRunProgress(
            eventID: eventID,
            usedRuns: 0,
            resetDay: today
        )
        saveProgress()
    }

    private static func maxHP(for stage: Int) -> Int {
        40 + stage * 18 + stage * stage / 2
    }

    private static func xpToNextLevel(for level: Int) -> Int {
        100 + max(level - 1, 0) * 35
    }

    private static func todayKey() -> String {
        let components = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: Date()
        )
        return
            "\(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)"
    }

    private struct ProgressSnapshot: Codable {
        let stage: Int
        let stageHP: Int
        let maxStageHP: Int
        let accountLevel: Int
        let accountXP: Int
        let prestigeCount: Int
        let artifactShards: Int
        let coins: Int
        let crystals: Int
        let pendingCoins: Int
        let pendingCrystals: Int
        let ownedSprites: [OwnedSprite]
        let ownedArtifacts: [OwnedArtifact]
        let eventCurrencies: [String: Int]
        let eventRunsByID: [String: EventRunProgress]

        init(
            stage: Int,
            stageHP: Int,
            maxStageHP: Int,
            accountLevel: Int,
            accountXP: Int,
            prestigeCount: Int,
            artifactShards: Int,
            coins: Int,
            crystals: Int,
            pendingCoins: Int,
            pendingCrystals: Int,
            ownedSprites: [OwnedSprite],
            ownedArtifacts: [OwnedArtifact],
            eventCurrencies: [String: Int],
            eventRunsByID: [String: EventRunProgress]
        ) {
            self.stage = stage
            self.stageHP = stageHP
            self.maxStageHP = maxStageHP
            self.accountLevel = accountLevel
            self.accountXP = accountXP
            self.prestigeCount = prestigeCount
            self.artifactShards = artifactShards
            self.coins = coins
            self.crystals = crystals
            self.pendingCoins = pendingCoins
            self.pendingCrystals = pendingCrystals
            self.ownedSprites = ownedSprites
            self.ownedArtifacts = ownedArtifacts
            self.eventCurrencies = eventCurrencies
            self.eventRunsByID = eventRunsByID
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            stage = try container.decodeIfPresent(Int.self, forKey: .stage) ?? 0
            maxStageHP =
                try container.decodeIfPresent(Int.self, forKey: .maxStageHP)
                ?? GameProgressStore.maxHP(for: stage)
            stageHP =
                try container.decodeIfPresent(Int.self, forKey: .stageHP)
                ?? maxStageHP
            accountLevel =
                try container.decodeIfPresent(Int.self, forKey: .accountLevel)
                ?? 1
            accountXP =
                try container.decodeIfPresent(Int.self, forKey: .accountXP) ?? 0
            prestigeCount =
                try container.decodeIfPresent(Int.self, forKey: .prestigeCount)
                ?? 0
            artifactShards =
                try container.decodeIfPresent(Int.self, forKey: .artifactShards)
                ?? 0
            coins = try container.decodeIfPresent(Int.self, forKey: .coins) ?? 0
            crystals =
                try container.decodeIfPresent(Int.self, forKey: .crystals) ?? 0
            pendingCoins =
                try container.decodeIfPresent(Int.self, forKey: .pendingCoins)
                ?? 0
            pendingCrystals =
                try container.decodeIfPresent(
                    Int.self,
                    forKey: .pendingCrystals
                ) ?? 0
            ownedSprites =
                try container.decodeIfPresent(
                    [OwnedSprite].self,
                    forKey: .ownedSprites
                ) ?? []
            ownedArtifacts =
                try container.decodeIfPresent(
                    [OwnedArtifact].self,
                    forKey: .ownedArtifacts
                ) ?? []
            eventCurrencies =
                try container.decodeIfPresent(
                    [String: Int].self,
                    forKey: .eventCurrencies
                ) ?? [:]
            eventRunsByID =
                try container.decodeIfPresent(
                    [String: EventRunProgress].self,
                    forKey: .eventRunsByID
                ) ?? [:]
        }
    }
}

struct OwnedSprite: Identifiable, Codable {
    var id: Int { spriteIndex }

    let spriteIndex: Int
    let name: String
    let imageName: String
    let rarity: SpriteRarity
    let stars: Int
}

struct SummonResult: Identifiable {
    let id = UUID()
    let entry: SummonEntry
    let isDuplicate: Bool
    let stars: Int
}

struct EventRunProgress: Codable {
    let eventID: String
    let usedRuns: Int
    let resetDay: String
}
