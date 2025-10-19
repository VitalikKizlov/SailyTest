//
//  StorageClient.swift
//  SailyTest
//
//  Created by Vitalii Kizlov on 19.10.2025.
//

import Foundation
import ComposableArchitecture

@DependencyClient
struct StorageClient {
    var saveServers: (_ servers: [Server]) throws -> Void
    var loadServers: () throws -> CachedServerList?
    var clearServers: () throws -> Void
    var hasCachedServers: () throws -> Bool
}

extension StorageClient: DependencyKey {
    static var liveValue: StorageClient {
        let storageWrapper = StorageWrapper()
        let serversKey = "cached_servers"
        
        return StorageClient(
            saveServers: { servers in
                @Dependency(\.date.now) var now
                let cachedList = CachedServerList(servers: servers, lastFetched: now)
                try storageWrapper.set(cachedList, forKey: serversKey)
            },
            loadServers: {
                try storageWrapper.get(CachedServerList.self, forKey: serversKey)
            },
            clearServers: {
                storageWrapper.remove(forKey: serversKey)
            },
            hasCachedServers: {
                storageWrapper.hasValue(forKey: serversKey)
            }
        )
    }
    
    static var testValue: StorageClient = StorageClient(
        saveServers: { _ in },
        loadServers: { nil },
        clearServers: { },
        hasCachedServers: { false }
    )
    
    static let previewValue: StorageClient = .mock
}

extension StorageClient {
    static let mock = StorageClient(
        saveServers: { _ in },
        loadServers: { 
            @Dependency(\.date.now) var now
            return CachedServerList(servers: Server.mock, lastFetched: now)
        },
        clearServers: { },
        hasCachedServers: { true }
    )
    
    static let failing = StorageClient(
        saveServers: { _ in throw StorageError.encodingFailed(NSError(domain: "test", code: 1)) },
        loadServers: { throw StorageError.decodingFailed(NSError(domain: "test", code: 1)) },
        clearServers: { },
        hasCachedServers: { false }
    )
}

extension DependencyValues {
    var storageClient: StorageClient {
        get { self[StorageClient.self] }
        set { self[StorageClient.self] = newValue }
    }
}
