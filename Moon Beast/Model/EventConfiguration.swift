//
//  EventConfiguration.swift
//  Moon Beast
//
//  Created by Tufan Cakir on 08.08.26.
//

import Foundation

struct EventConfiguration: Decodable {
    let events: [GameEvent]

    static func load(named resourceName: String = "event") throws
        -> EventConfiguration
    {
        try JSONLoader.load(named: resourceName)
    }
}

struct GameEvent: Decodable, Identifiable {
    let id: String
    let title: String
    let bannerImageName: String
    let currencyName: String
    let currencyImageName: String
    let dailyLimit: Int
    let hp: Int
    let rewards: EventRewards
}

struct EventRewards: Decodable {
    let eventCurrency: Int
    let coins: Int
    let crystals: Int
}
