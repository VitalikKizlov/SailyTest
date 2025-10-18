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
        .init(name: "Germany #26", distance: 300)
    ]
}
