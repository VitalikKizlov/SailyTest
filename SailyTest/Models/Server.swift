//
//  Server.swift
//  SailyTest
//
//  Created by Vitalii Kizlov on 18.10.2025.
//

import Foundation
import ComposableArchitecture

struct Server: Codable, Hashable, Identifiable {
    let id: UUID
    let name: String
    let distance: Int
    
    init(id: UUID, name: String, distance: Int) {
        self.id = id
        self.name = name
        self.distance = distance
    }
    
    // CodingKeys to exclude id from JSON decoding
    private enum CodingKeys: String, CodingKey {
        case name, distance
    }
    
    // Custom decoder to handle missing id field
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        @Dependency(\.uuid) var uuid
        self.id = uuid()
        self.name = try container.decode(String.self, forKey: .name)
        self.distance = try container.decode(Int.self, forKey: .distance)
    }
    
    // Custom encoder to exclude id from JSON encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(distance, forKey: .distance)
    }
    
    // Custom Hashable implementation based on name for deduplication
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: Server, rhs: Server) -> Bool {
        lhs.name == rhs.name
    }
}

extension Server {
    @Dependency(\.uuid) static var uuid
    
    static var mock: [Server] {
        [
            .init(id: uuid(), name: "United Kingdom #68", distance: 100),
            .init(id: uuid(), name: "Latvia #95", distance: 200),
            .init(id: uuid(), name: "Germany #26", distance: 300),
            .init(id: uuid(), name: "United States #12", distance: 150),
            .init(id: uuid(), name: "Netherlands #44", distance: 250),
            .init(id: uuid(), name: "France #77", distance: 180),
            .init(id: uuid(), name: "Sweden #33", distance: 220),
            .init(id: uuid(), name: "Norway #19", distance: 190),
            .init(id: uuid(), name: "Denmark #55", distance: 210),
            .init(id: uuid(), name: "Finland #88", distance: 240),
            .init(id: uuid(), name: "Poland #66", distance: 170),
            .init(id: uuid(), name: "Czech Republic #41", distance: 160),
            .init(id: uuid(), name: "Austria #73", distance: 230),
            .init(id: uuid(), name: "Switzerland #29", distance: 200),
            .init(id: uuid(), name: "Italy #52", distance: 280),
            .init(id: uuid(), name: "Spain #84", distance: 320),
            .init(id: uuid(), name: "Portugal #37", distance: 350),
            .init(id: uuid(), name: "Belgium #61", distance: 140),
            .init(id: uuid(), name: "Luxembourg #15", distance: 130),
            .init(id: uuid(), name: "Ireland #78", distance: 120),
            .init(id: uuid(), name: "Iceland #92", distance: 400),
            .init(id: uuid(), name: "Estonia #46", distance: 260),
            .init(id: uuid(), name: "Lithuania #83", distance: 270),
            .init(id: uuid(), name: "Slovakia #58", distance: 290),
            .init(id: uuid(), name: "Slovenia #24", distance: 310),
            .init(id: uuid(), name: "Croatia #67", distance: 330),
            .init(id: uuid(), name: "Hungary #39", distance: 340),
            .init(id: uuid(), name: "Romania #71", distance: 360),
            .init(id: uuid(), name: "Bulgaria #85", distance: 380),
            .init(id: uuid(), name: "Greece #13", distance: 420)
        ]
    }
}
