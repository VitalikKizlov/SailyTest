//
//  ServersListTests.swift
//  SailyTestTests
//
//  Created by Vitalii Kizlov on 19.10.2025.
//

import XCTest
import ComposableArchitecture
@testable import SailyTest

@MainActor
final class ServersListTests: XCTestCase {
    
    // MARK: - Test Helper
    
    private func makeTestStore(
        initialState: ServersList.State = ServersList.State(),
        storageClient: StorageClient = .mock,
        serversProvider: ServersProvider = .mock,
        keychainClient: KeychainClient = .mock
    ) -> TestStore<ServersList.State, ServersList.Action> {
        let store = TestStore(initialState: initialState) {
            ServersList()
        } withDependencies: {
            $0.storageClient = storageClient
            $0.serversProvider = serversProvider
            $0.keychainClient = keychainClient
            $0.mainQueue = .immediate
            $0.uuid = .incrementing
        }
        
        store.exhaustivity = .off
        return store
    }
    
    
    // MARK: - Test App Launch with Cached Data
    
    func testOnAppear_WithValidCache_ShouldLoadCachedServers() async {
        let store = makeTestStore(
            storageClient: StorageClient(
                saveServers: { _ in },
                loadServers: { 
                    CachedServerList(servers: [
                        Server(id: UUID(0), name: "United Kingdom #68", distance: 100),
                        Server(id: UUID(1), name: "Latvia #95", distance: 200)
                    ])
                },
                clearServers: { },
                hasCachedServers: { true }
            )
        )
        
        await store.send(.onAppear)
        await store.receive(.serversFetched([
            Server(id: UUID(0), name: "United Kingdom #68", distance: 100),
            Server(id: UUID(1), name: "Latvia #95", distance: 200)
        ])) {
            $0.servers = [
                Server(id: UUID(0), name: "United Kingdom #68", distance: 100),
                Server(id: UUID(1), name: "Latvia #95", distance: 200)
            ]
        }
        await store.receive(.setLoadingState(.loaded)) {
            $0.loadingState = .loaded
        }
    }
    
    func testOnAppear_WithExpiredCache_ShouldFetchFromAPI() async {
        let store = makeTestStore(
            storageClient: StorageClient(
                saveServers: { _ in },
                loadServers: { 
                    CachedServerList(
                        servers: [Server(id: UUID(0), name: "United Kingdom #68", distance: 100)], 
                        cacheExpiry: -1 // Expired immediately
                    )
                },
                clearServers: { },
                hasCachedServers: { true }
            ),
            serversProvider: ServersProvider { 
                [
                    Server(id: UUID(0), name: "United Kingdom #68", distance: 100),
                    Server(id: UUID(1), name: "Latvia #95", distance: 200)
                ]
            }
        )

        store.exhaustivity = .on

        await store.send(.onAppear)
        await store.receive(.fetchServers)
        await store.receive(.setLoadingState(.loading)) {
            $0.loadingState = .loading
        }
        await store.receive(.serversFetched([
            Server(id: UUID(0), name: "United Kingdom #68", distance: 100),
            Server(id: UUID(1), name: "Latvia #95", distance: 200)
        ])) {
            $0.servers = [
                Server(id: UUID(0), name: "United Kingdom #68", distance: 100),
                Server(id: UUID(1), name: "Latvia #95", distance: 200)
            ]
        }
        await store.receive(.setLoadingState(.loaded)) {
            $0.loadingState = .loaded
        }
    }
    
    func testOnAppear_WithNoCache_ShouldFetchFromAPI() async {
        let store = makeTestStore(
            storageClient: StorageClient(
                saveServers: { _ in },
                loadServers: { nil },
                clearServers: { },
                hasCachedServers: { false }
            ),
            serversProvider: ServersProvider { 
                [
                    Server(id: UUID(0), name: "United Kingdom #68", distance: 100),
                    Server(id: UUID(1), name: "Latvia #95", distance: 200)
                ]
            }
        )
        
        await store.send(.onAppear)
        await store.receive(.fetchServers)
        await store.receive(.setLoadingState(.loading)) {
            $0.loadingState = .loading
        }
        await store.receive(.serversFetched([
            Server(id: UUID(0), name: "United Kingdom #68", distance: 100),
            Server(id: UUID(1), name: "Latvia #95", distance: 200)
        ])) {
            $0.servers = [
                Server(id: UUID(0), name: "United Kingdom #68", distance: 100),
                Server(id: UUID(1), name: "Latvia #95", distance: 200)
            ]
        }
        await store.receive(.setLoadingState(.loaded)) {
            $0.loadingState = .loaded
        }
    }
    
    // MARK: - Test Server Fetching
    
    func testFetchServers_NetworkError_ShouldHandleGracefully() async {
        let store = makeTestStore(
            storageClient: StorageClient(
                saveServers: { _ in },
                loadServers: { nil },
                clearServers: { },
                hasCachedServers: { false }
            ),
            serversProvider: ServersProvider {
                throw URLError(.notConnectedToInternet) // Network error, not auth error
            }
        )
        
        await store.send(.fetchServers)
        await store.receive(.setLoadingState(.loading)) {
            $0.loadingState = .loading
        }
        await store.receive(.fetchFailed)
        await store.receive(.setLoadingState(.loaded)) {
            $0.loadingState = .loaded
        }
    }
    
    func testFetchServers_AuthError_ShouldNotifyParent() async {
        let store = makeTestStore(
            storageClient: StorageClient(
                saveServers: { _ in },
                loadServers: { nil },
                clearServers: { },
                hasCachedServers: { false }
            ),
            serversProvider: .failing // This throws URLError(.userAuthenticationRequired)
        )
        
        await store.send(.fetchServers)
        await store.receive(.setLoadingState(.loading)) {
            $0.loadingState = .loading
        }
        await store.receive(.authFailed)
        await store.receive(.setLoadingState(.loaded)) {
            $0.loadingState = .loaded
        }
    }
    
    // MARK: - Test Sorting
    
    func testSortByDistance_ShouldSortServersByDistance() async {
        let servers = [
            Server(id: UUID(0), name: "Far Server", distance: 1000),
            Server(id: UUID(1), name: "Close Server", distance: 100)
        ]
        
        let store = makeTestStore(
            initialState: ServersList.State(servers: IdentifiedArrayOf(uniqueElements: servers))
        )
        
        // First, tap the filter button to show the dialog
        await store.send(.didTapFilterButton) {
            $0.confirmationDialog = ConfirmationDialogState {
                TextState("Sort by")
            } actions: {
                ButtonState(action: .sortByDistance) {
                    TextState("By distance")
                }
                ButtonState(action: .sortAlphabetically) {
                    TextState("Alphabetical")
                }
            }
        }
        
        // Then, tap the sort by distance button
        await store.send(.confirmationDialog(.presented(.sortByDistance))) {
            $0.servers = [
                Server(id: UUID(1), name: "Close Server", distance: 100),
                Server(id: UUID(0), name: "Far Server", distance: 1000)
            ]
            $0.confirmationDialog = nil
        }
    }
    
    func testSortAlphabetically_ShouldSortServersByName() async {
        let servers = [
            Server(id: UUID(0), name: "Zebra Server", distance: 100),
            Server(id: UUID(1), name: "Alpha Server", distance: 200)
        ]
        
        let store = makeTestStore(
            initialState: ServersList.State(servers: IdentifiedArrayOf(uniqueElements: servers))
        )
        
        // First, tap the filter button to show the dialog
        await store.send(.didTapFilterButton) {
            $0.confirmationDialog = ConfirmationDialogState {
                TextState("Sort by")
            } actions: {
                ButtonState(action: .sortByDistance) {
                    TextState("By distance")
                }
                ButtonState(action: .sortAlphabetically) {
                    TextState("Alphabetical")
                }
            }
        }
        
        // Then, tap the sort alphabetically button
        await store.send(.confirmationDialog(.presented(.sortAlphabetically))) {
            $0.servers = [
                Server(id: UUID(1), name: "Alpha Server", distance: 200),
                Server(id: UUID(0), name: "Zebra Server", distance: 100)
            ]
            $0.confirmationDialog = nil
        }
    }
    
    // MARK: - Test Filter Dialog
    
    func testDidTapFilterButton_ShouldShowConfirmationDialog() async {
        let store = makeTestStore()
        
        await store.send(.didTapFilterButton) {
            $0.confirmationDialog = ConfirmationDialogState {
                TextState("Sort by")
            } actions: {
                ButtonState(action: .sortByDistance) {
                    TextState("By distance")
                }
                ButtonState(action: .sortAlphabetically) {
                    TextState("Alphabetical")
                }
            }
        }
    }
    
    func testConfirmationDialogDismiss_ShouldHideDialog() async {
        let store = makeTestStore()
        
        // First show the dialog
        await store.send(.didTapFilterButton) {
            $0.confirmationDialog = ConfirmationDialogState {
                TextState("Sort by")
            } actions: {
                ButtonState(action: .sortByDistance) {
                    TextState("By distance")
                }
                ButtonState(action: .sortAlphabetically) {
                    TextState("Alphabetical")
                }
            }
        }
        
        // Then dismiss it
        await store.send(.confirmationDialog(.dismiss)) {
            $0.confirmationDialog = nil
        }
    }
    
    // MARK: - Test Logout
    
    func testDidTapLogoutButton_ShouldClearKeychain() async {
        var keychainCleared = false
        
        let store = makeTestStore(
            keychainClient: KeychainClient(
                storeValue: { _, _ in },
                storeToken: { _ in },
                getCredentials: { UserCredentials(name: "test", pass: "test") },
                getToken: { Token.mock },
                clearAll: { keychainCleared = true }
            )
        )
        
        await store.send(.didTapLogoutButton)
        
        XCTAssertTrue(keychainCleared, "Keychain should be cleared on logout")
    }
}
