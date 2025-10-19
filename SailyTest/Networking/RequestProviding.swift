//
//  RequestProviding.swift
//  SailyTest
//
//  Created by Vitalii Kizlov on 18.10.2025.
//

import Foundation
import ComposableArchitecture

protocol RequestProviding {
    func urlRequest() -> URLRequest
}

enum Endpoint: RequestProviding {
    case getToken(creds: UserCredentials)
    case getServerList

    private static let scheme = "https"
    private static let baseURLString = "playground.nordsec.com"
    
    // MARK: - Dependency Injection
    @Dependency(\.keychainClient) private static var keychainClient

    // MARK: - Configuration
    private static let defaultHeaders: [String: String] = [
        "Content-Type": "application/json",
        "Accept": "application/json"
    ]

    private enum HTTPMethod {
        case get
        case post

        var value: String {
            switch self {
            case .get: return "GET"
            case .post: return "POST"
            }
        }
    }

    private var method: HTTPMethod {
        switch self {
        case .getToken:
            return .post
        case .getServerList:
            return .get
        }
    }

    private var path: String {
        switch self {
        case .getToken:
            return "/v1/tokens"
        case .getServerList:
            return "/v1/servers"
        }
    }

    private var parameters: [String: String] {
        switch self {
        case .getToken(let creds):
            return ["username": creds.name, "password": creds.pass]
        case .getServerList:
            return [:]
        }
    }

    func urlRequest() -> URLRequest {
        var components = URLComponents()
        components.scheme = Endpoint.scheme
        components.host = Endpoint.baseURLString
        components.path = path
        components.queryItems = parameters.compactMap { URLQueryItem(name: $0.key, value: $0.value)}

        guard let url = components.url else {
            preconditionFailure("Can't create URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.value
        
        // Add default headers
        for (key, value) in Endpoint.defaultHeaders {
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        // Add authorization header for protected endpoints
        if requiresAuth {
            if let token = getCurrentToken() {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }
        
        #if DEBUG
        print("🌐 API Request: \(method.value) \(url)")
        if let authHeader = request.value(forHTTPHeaderField: "Authorization") {
            print("🔐 Authorization: \(authHeader.prefix(20))...")
        }
        #endif
        
        return request
    }
    
    // MARK: - Helper Properties
    
    private var requiresAuth: Bool {
        switch self {
        case .getToken:
            return false // Login endpoint doesn't need auth
        case .getServerList:
            return true // Servers endpoint needs auth
        }
    }
    
    private func getCurrentToken() -> String? {
        do {
            let token = try Self.keychainClient.getToken()
            return token.token
        } catch {
            return nil
        }
    }
}
