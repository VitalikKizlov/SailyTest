//
//  TokenProvider.swift
//  SailyTest
//
//  Created by Vitalii Kizlov on 18.10.2025.
//

import Foundation
import ComposableArchitecture

@DependencyClient
struct TokenProvider {
    var getToken: (_ creds: UserCredentials) async throws -> Token
}

extension TokenProvider: DependencyKey {

    static var liveValue: TokenProvider {
        return TokenProvider { creds in
            return try await APISession().execute(Endpoint.getToken(creds: creds))
        }
    }

    static var testValue: TokenProvider = .init()

    static let previewValue: TokenProvider = .mock
}

extension TokenProvider {
    @Dependency(\.mainQueue) static var mainQueue

    static let mock = TokenProvider { _ in
        try await mainQueue.sleep(for: .seconds(.random(in: 0.1...0.8)))
        return .mock
    }
    
    static let failing = TokenProvider { _ in
        throw URLError(.userAuthenticationRequired)
    }
}

extension DependencyValues {
    var tokenProvider: TokenProvider {
        get { self[TokenProvider.self] }
        set { self[TokenProvider.self] = newValue }
    }
}
