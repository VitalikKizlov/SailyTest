//
//  APISession.swift
//  SailyTest
//
//  Created by Vitalii Kizlov on 18.10.2025.
//

import Foundation

protocol APISessionProviding {
    func execute<T: Codable>(_ requestProvider: RequestProviding) async throws -> T
}

struct APISession: APISessionProviding {
    let decoder = JSONDecoder()
    
    func execute<T>(_ requestProvider: RequestProviding) async throws -> T where T : Codable {
        let (data, response) = try await URLSession.shared.data(for: requestProvider.urlRequest())
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode == 401 {
            throw URLError(.userAuthenticationRequired)
        }
        
        return try decoder.decode(T.self, from: data)
    }
}
