//
//  KeychainWrapper.swift
//  SailyTest
//
//  Created by Vitalii Kizlov on 18.10.2025.
//

import Foundation
import ComposableArchitecture

private func throwIfError(_ status: OSStatus, _ ctx: String = "") throws {
    guard status == errSecSuccess else { throw KeychainWrapper.KeychainError(status: status, context: ctx) }
}

final class KeychainWrapper {
    enum Key: String { case username, password, token }

    struct KeychainError: Error {
        let status: OSStatus
        let context: String

        var localizedDescription: String {
            let statusString = SecCopyErrorMessageString(status, nil) ?? "Unknown error" as CFString
            return "Keychain error in \(context): \(statusString) (status: \(status))"
        }
    }

    private let service: String
    private let accessibility = kSecAttrAccessibleWhenUnlocked

    init(service: String = Bundle.main.bundleIdentifier ?? "app") {
        self.service = service
    }

    func set(_ value: String, for key: KeychainWrapper.Key) throws {
        try set(Data(value.utf8), for: key)
    }

    func get(_ key: KeychainWrapper.Key) throws -> String? {
        guard let data = try getData(key) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func delete(_ key: KeychainWrapper.Key) throws {
        let q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue
        ]
        let s = SecItemDelete(q as CFDictionary)
        if s != errSecSuccess && s != errSecItemNotFound { try throwIfError(s, "delete") }
    }

    // MARK: - Data helpers
    func set(_ data: Data, for key: KeychainWrapper.Key) throws {
        let base: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecAttrAccessible as String: accessibility
        ]
        var q = base
        q[kSecValueData as String] = data

        let add = SecItemAdd(q as CFDictionary, nil)
        if add == errSecDuplicateItem {
            let upd = SecItemUpdate(base as CFDictionary, [kSecValueData as String: data] as CFDictionary)
            try throwIfError(upd, "update")
        } else {
            try throwIfError(add, "add")
        }
    }

    func getData(_ key: KeychainWrapper.Key) throws -> Data? {
        let q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]
        var item: CFTypeRef?
        let s = SecItemCopyMatching(q as CFDictionary, &item)
        if s == errSecItemNotFound { return nil }
        try throwIfError(s, "copy")
        return item as? Data
    }
}
