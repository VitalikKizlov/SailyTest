//
//  ServersProvider.swift
//  SailyTest
//
//  Created by Vitalii Kizlov on 18.10.2025.
//

import Foundation
import ComposableArchitecture

@DependencyClient
struct ServersProvider {
    var servers: () async throws -> [Server]
}

extension ServersProvider: DependencyKey {
    static var liveValue: ServersProvider {
        ServersProvider {
            return try await APISession().execute(Endpoint.getServerList)
        }
    }

    static var testValue: ServersProvider = .init()

    static let previewValue: ServersProvider = .mock
}

extension ServersProvider {
    @Dependency(\.mainQueue) static var mainQueue

    static let mock = ServersProvider {
        try await mainQueue.sleep(for: .seconds(.random(in: 0.1...0.8)))
        return Server.mock
    }

    static let failing = ServersProvider {
        throw URLError(.userAuthenticationRequired)
    }
}

extension DependencyValues {
    var serverProvider: ServersProvider {
        get { self[ServersProvider.self] }
        set { self[ServersProvider.self] = newValue }
    }
}
