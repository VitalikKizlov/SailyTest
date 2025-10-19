//
//  AppTests.swift
//  SailyTestTests
//
//  Created by Vitalii Kizlov on 19.10.2025.
//

import Foundation
import XCTest
import ComposableArchitecture
@testable import SailyTest

@MainActor
final class AppTests: XCTestCase {
    
    // MARK: - Test App Launch with No Credentials
    
    func testAppLaunchWithNoCredentials_ShouldShowLogin() async {
        let store = TestStore(initialState: AppReducer.State()) {
            AppReducer()
        } withDependencies: {
            $0.keychainClient = .failing
        }

        store.exhaustivity = .off

        await store.send(.onAppear)
        await store.receive(.checkCredentials)
        
        await store.receive(.credentialsNotFound) {
            $0.contentMode = .login(Login.State())
        }
    }
    
    // MARK: - Test App Launch with Existing Credentials
    
    func testAppLaunchWithExistingCredentials_ShouldShowServersList() async {
        let store = TestStore(initialState: AppReducer.State()) {
            AppReducer()
        } withDependencies: {
            $0.keychainClient = .mock
        }

        store.exhaustivity = .off

        await store.send(.onAppear)
        await store.receive(.checkCredentials)

        await store.receive(.credentialsFound) {
            $0.contentMode = .serversList(ServersList.State())
        }
    }
    
    // MARK: - Test Successful Login Navigation
    
    func testSuccessfulLogin_ShouldNavigateToServersList() async {
        let store = TestStore(initialState: AppReducer.State()) {
            AppReducer()
        } withDependencies: {
            $0.keychainClient = .failing  // Start with no credentials to get to login
        }

        store.exhaustivity = .off

        // Navigate to login screen first
        await store.send(.onAppear)
        await store.receive(.checkCredentials)
        await store.receive(.credentialsNotFound) {
            $0.contentMode = .login(Login.State())
        }
        
        // Now test successful login
        await store.send(.contentMode(.login(.loginSucceeded(Token.mock)))) {
            $0.contentMode = .serversList(ServersList.State())
        }
    }
    
    // MARK: - Test Logout Navigation
    
    func testLogout_ShouldNavigateToLogin() async {
        let store = TestStore(initialState: AppReducer.State()) {
            AppReducer()
        } withDependencies: {
            $0.keychainClient = .mock  // Start with existing credentials to get to servers list
        }

        store.exhaustivity = .off

        // Navigate to servers list screen first
        await store.send(.onAppear)
        await store.receive(.checkCredentials)
        await store.receive(.credentialsFound) {
            $0.contentMode = .serversList(ServersList.State())
        }
        
        // Now test logout
        await store.send(.contentMode(.serversList(.didTapLogoutButton))) {
            $0.contentMode = .login(Login.State())
        }
    }
}
