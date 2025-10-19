//
//  StorageWrapper.swift
//  SailyTest
//
//  Created by Vitalii Kizlov on 19.10.2025.
//

import Foundation

final class StorageWrapper {
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - Generic Storage Operations
    
    func set<T: Codable>(_ value: T, forKey key: String) throws {
        do {
            let data = try JSONEncoder().encode(value)
            userDefaults.set(data, forKey: key)
        } catch {
            throw StorageError.encodingFailed(error)
        }
    }
    
    func get<T: Codable>(_ type: T.Type, forKey key: String) throws -> T? {
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw StorageError.decodingFailed(error)
        }
    }
    
    func remove(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
    
    func hasValue(forKey key: String) -> Bool {
        return userDefaults.object(forKey: key) != nil
    }
}

// MARK: - Storage Errors

enum StorageError: Error {
    case encodingFailed(Error)
    case decodingFailed(Error)
    
    var localizedDescription: String {
        switch self {
        case .encodingFailed(let error):
            return "Failed to encode data: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        }
    }
}
