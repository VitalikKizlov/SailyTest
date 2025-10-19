//
//  KeychainClient.swift
//  SailyTest
//
//  Created by Vitalii Kizlov on 18.10.2025.
//

import Foundation
import ComposableArchitecture

@DependencyClient
struct KeychainClient {
    var storeValue: (_ value: String, _ key: KeychainWrapper.Key) throws -> Void
    var storeToken: (_ token: Token) throws -> Void
    var getCredentials: () throws -> UserCredentials
    var getToken: () throws -> Token
    var clearAll: () throws -> Void
}

extension KeychainClient: DependencyKey {
    static var liveValue: KeychainClient {
        let keychainWrapper = KeychainWrapper()

        return KeychainClient(
            storeValue: { value, key in
                try keychainWrapper.set(value, for: key)
            },
            storeToken: { token in
                try keychainWrapper.set(token.token, for: .token)
            },
            getCredentials: {
                guard
                    let username = try keychainWrapper.get(.username),
                    let password = try keychainWrapper.get(.password)
                else {
                    throw KeychainWrapper.KeychainError(status: errSecItemNotFound, context: "getCredentials")
                }
                return UserCredentials(name: username, pass: password)
            },
            getToken: {
                guard let tokenString = try keychainWrapper.get(.token) else {
                    throw KeychainWrapper.KeychainError(status: errSecItemNotFound, context: "getToken")
                }
                return Token(token: tokenString)
            },
            clearAll: {
                try keychainWrapper.delete(.username)
                try keychainWrapper.delete(.password)
                try keychainWrapper.delete(.token)
            }
        )
    }

    static var testValue: KeychainClient = .init()

    static let previewValue: KeychainClient = .mock
}

extension KeychainClient {
    static let mock = KeychainClient(
        storeValue: { _, _ in },
        storeToken: { _ in },
        getCredentials: { UserCredentials(name: "test", pass: "test") },
        getToken: { Token.mock },
        clearAll: { }
    )
    
    static let failing = KeychainClient(
        storeValue: { _, _ in throw KeychainWrapper.KeychainError(status: errSecItemNotFound, context: "test") },
        storeToken: { _ in throw KeychainWrapper.KeychainError(status: errSecItemNotFound, context: "test") },
        getCredentials: { throw KeychainWrapper.KeychainError(status: errSecItemNotFound, context: "test") },
        getToken: { throw KeychainWrapper.KeychainError(status: errSecItemNotFound, context: "test") },
        clearAll: { throw KeychainWrapper.KeychainError(status: errSecItemNotFound, context: "test") }
    )
}

extension DependencyValues {
    var keychainClient: KeychainClient {
        get { self[KeychainClient.self] }
        set { self[KeychainClient.self] = newValue }
    }
}

