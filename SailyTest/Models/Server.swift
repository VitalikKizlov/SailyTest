//
//  Server.swift
//  SailyTest
//
//  Created by Vitalii Kizlov on 18.10.2025.
//

import Foundation

struct Server: Codable, Hashable, Identifiable {
    var id: String { name }

    let name: String
    let distance: Int
}

extension Server {
    static let mock: [Server] = [
        .init(name: "United Kingdom #68", distance: 100),
        .init(name: "Latvia #95", distance: 200),
        .init(name: "Germany #26", distance: 300),
        .init(name: "United States #12", distance: 150),
        .init(name: "Netherlands #44", distance: 250),
        .init(name: "France #77", distance: 180),
        .init(name: "Sweden #33", distance: 220),
        .init(name: "Norway #19", distance: 190),
        .init(name: "Denmark #55", distance: 210),
        .init(name: "Finland #88", distance: 240),
        .init(name: "Poland #66", distance: 170),
        .init(name: "Czech Republic #41", distance: 160),
        .init(name: "Austria #73", distance: 230),
        .init(name: "Switzerland #29", distance: 200),
        .init(name: "Italy #52", distance: 280),
        .init(name: "Spain #84", distance: 320),
        .init(name: "Portugal #37", distance: 350),
        .init(name: "Belgium #61", distance: 140),
        .init(name: "Luxembourg #15", distance: 130),
        .init(name: "Ireland #78", distance: 120),
        .init(name: "Iceland #92", distance: 400),
        .init(name: "Estonia #46", distance: 260),
        .init(name: "Lithuania #83", distance: 270),
        .init(name: "Slovakia #58", distance: 290),
        .init(name: "Slovenia #24", distance: 310),
        .init(name: "Croatia #67", distance: 330),
        .init(name: "Hungary #39", distance: 340),
        .init(name: "Romania #71", distance: 360),
        .init(name: "Bulgaria #85", distance: 380),
        .init(name: "Greece #13", distance: 420)
    ]
}
