//
//  Token.swift
//  SailyTest
//
//  Created by Vitalii Kizlov on 18.10.2025.
//

import Foundation

struct Token: Codable, Equatable {
    let token: String
}

extension Token {
    static let mock = Token(token: "111111111111")
}
