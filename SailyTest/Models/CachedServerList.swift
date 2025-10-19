//
//  CachedServerList.swift
//  SailyTest
//
//  Created by Vitalii Kizlov on 19.10.2025.
//

import Foundation
import ComposableArchitecture

struct CachedServerList: Codable, Equatable {
    let servers: [Server]
    let lastFetched: Date
    let cacheExpiry: TimeInterval
    
    init(servers: [Server], lastFetched: Date, cacheExpiry: TimeInterval = 300) {
        self.servers = servers
        self.lastFetched = lastFetched
        self.cacheExpiry = cacheExpiry
    }
    
    // MARK: - Cache Validation
    
    var isExpired: Bool {
        @Dependency(\.date.now) var now
        return now.timeIntervalSince(lastFetched) > cacheExpiry
    }
    
    var shouldRefresh: Bool {
        isExpired
    }
    
    // MARK: - Future Production Enhancements
    // For production apps we have to consider implementing other strategies:
    // - Hash-based change detection to avoid unnecessary API calls
    // - ETag/Last-Modified headers from server
    // - Cache invalidation policies
}
