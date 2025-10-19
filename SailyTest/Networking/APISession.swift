//
//  APISession.swift
//  SailyTest
//
//  Created by Vitalii Kizlov on 18.10.2025.
//

import Foundation
import ComposableArchitecture

protocol APISessionProviding {
    func execute<T: Codable>(_ requestProvider: RequestProviding) async throws -> T
}

struct APISession: APISessionProviding {
    let decoder = JSONDecoder()
    @Dependency(\.keychainClient) private var keychainClient
    
    func execute<T>(_ requestProvider: RequestProviding) async throws -> T where T : Codable {
        return try await executeWithRetry(requestProvider)
    }
    
    private func executeWithRetry<T: Codable>(_ requestProvider: RequestProviding) async throws -> T {
        // First attempt
        let (data, response) = try await URLSession.shared.data(for: requestProvider.urlRequest())
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        // Check if we got a 401
        if httpResponse.statusCode == 401 {
            // Try to get a new token and retry once
            do {
                try await refreshToken()
                // Retry the original request with new token
                let (retryData, retryResponse) = try await URLSession.shared.data(for: requestProvider.urlRequest())
                
                guard let retryHttpResponse = retryResponse as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                if retryHttpResponse.statusCode == 401 {
                    throw URLError(.userAuthenticationRequired)
                }
                
                return try decoder.decode(T.self, from: retryData)
            } catch {
                // Refresh failed, throw auth error
                throw URLError(.userAuthenticationRequired)
            }
        }
        
        return try decoder.decode(T.self, from: data)
    }
    
    private func refreshToken() async throws {
        // Get stored credentials and make a new token request
        let credentials = try keychainClient.getCredentials()
        let (data, response) = try await URLSession.shared.data(for: Endpoint.getToken(creds: credentials).urlRequest())
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode == 401 {
            throw URLError(.userAuthenticationRequired)
        }
        
        let newToken = try decoder.decode(Token.self, from: data)
        try keychainClient.storeToken(newToken)
    }
}
