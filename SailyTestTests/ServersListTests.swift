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
        }
        
        store.exhaustivity = .off
        return store
    }
    
    // MARK: - Test App Launch with Cached Data
    
    func testOnAppear_WithValidCache_ShouldLoadCachedServers() async {
        let cachedServers = [Server.mock[0], Server.mock[1]]
        let cachedList = CachedServerList(servers: cachedServers)
        
        let store = makeTestStore(
            storageClient: StorageClient(
                saveServers: { _ in },
                loadServers: { cachedList },
                clearServers: { },
                hasCachedServers: { true }
            )
        )
        
        await store.send(.onAppear)
        await store.receive(.serversFetched(cachedServers)) {
            $0.servers = IdentifiedArrayOf(uniqueElements: cachedServers)
        }
        await store.receive(.setLoadingState(.loaded)) {
            $0.loadingState = .loaded
        }
    }
    
    func testOnAppear_WithExpiredCache_ShouldFetchFromAPI() async {
        let expiredCache = CachedServerList(
            servers: [Server.mock[0]], 
            cacheExpiry: -1 // Expired immediately
        )
        
        let store = makeTestStore(
            storageClient: StorageClient(
                saveServers: { _ in },
                loadServers: { expiredCache },
                clearServers: { },
                hasCachedServers: { true }
            )
        )
        
        await store.send(.onAppear)
        await store.receive(.fetchServers)
        await store.receive(.setLoadingState(.loading)) {
            $0.loadingState = .loading
        }
        await store.receive(.serversFetched(Server.mock)) {
            $0.servers = IdentifiedArrayOf(uniqueElements: Server.mock)
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
            )
        )
        
        await store.send(.onAppear)
        await store.receive(.fetchServers)
        await store.receive(.setLoadingState(.loading)) {
            $0.loadingState = .loading
        }
        await store.receive(.serversFetched(Server.mock)) {
            $0.servers = IdentifiedArrayOf(uniqueElements: Server.mock)
        }
        await store.receive(.setLoadingState(.loaded)) {
            $0.loadingState = .loaded
        }
    }
    
    // MARK: - Test Server Fetching
    
    func testFetchServers_Success_ShouldSaveToCache() async {
        let store = makeTestStore(
            storageClient: StorageClient(
                saveServers: { servers in
                    // Verify servers are saved
                    XCTAssertEqual(servers.count, Server.mock.count)
                },
                loadServers: { nil },
                clearServers: { },
                hasCachedServers: { false }
            )
        )
        
        await store.send(.fetchServers)
        await store.receive(.setLoadingState(.loading)) {
            $0.loadingState = .loading
        }
        await store.receive(.serversFetched(Server.mock)) {
            $0.servers = IdentifiedArrayOf(uniqueElements: Server.mock)
        }
        await store.receive(.setLoadingState(.loaded)) {
            $0.loadingState = .loaded
        }
    }
    
    func testFetchServers_WithDuplicates_ShouldRemoveDuplicates() async {
        let serversWithDuplicates = [
            Server(name: "UK #1", distance: 100),
            Server(name: "UK #1", distance: 200), // Duplicate
            Server(name: "US #2", distance: 300)
        ]
        
        let store = makeTestStore(
            storageClient: StorageClient(
                saveServers: { servers in
                    // Should save only unique servers
                    XCTAssertEqual(servers.count, 2)
                },
                loadServers: { nil },
                clearServers: { },
                hasCachedServers: { false }
            ),
            serversProvider: ServersProvider { serversWithDuplicates }
        )
        
        await store.send(.fetchServers)
        await store.receive(.setLoadingState(.loading)) {
            $0.loadingState = .loading
        }
        await store.receive(.serversFetched(serversWithDuplicates)) {
            // Should have only 2 unique servers
            $0.servers = IdentifiedArrayOf(uniqueElements: Array(Set(serversWithDuplicates)))
        }
        await store.receive(.setLoadingState(.loaded)) {
            $0.loadingState = .loaded
        }
    }
    
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
            Server(name: "Far Server", distance: 1000),
            Server(name: "Close Server", distance: 100)
        ]
        
        let store = makeTestStore(
            initialState: ServersList.State(servers: IdentifiedArrayOf(uniqueElements: servers))
        )
        
        await store.send(.confirmationDialog(.presented(.sortByDistance))) {
            $0.servers = IdentifiedArrayOf(uniqueElements: [
                Server(name: "Close Server", distance: 100),
                Server(name: "Far Server", distance: 1000)
            ])
        }
    }
    
    func testSortAlphabetically_ShouldSortServersByName() async {
        let servers = [
            Server(name: "Zebra Server", distance: 100),
            Server(name: "Alpha Server", distance: 200)
        ]
        
        let store = makeTestStore(
            initialState: ServersList.State(servers: IdentifiedArrayOf(uniqueElements: servers))
        )
        
        await store.send(.confirmationDialog(.presented(.sortAlphabetically))) {
            $0.servers = IdentifiedArrayOf(uniqueElements: [
                Server(name: "Alpha Server", distance: 200),
                Server(name: "Zebra Server", distance: 100)
            ])
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
