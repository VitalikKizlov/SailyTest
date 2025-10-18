//
//  ServersList.swift
//  SailyTest
//
//  Created by Vitalii Kizlov on 18.10.2025.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ServersList {
    enum LoadingState: Equatable {
        case idle
        case loading
        case loaded
    }

    @ObservableState
    struct State: Equatable {
        var loadingState: LoadingState = .idle
        var servers: IdentifiedArrayOf<Server> = []
    }

    enum Action: Equatable {
        case onAppear
        case didTapFilterButton
        case didTapLogoutButton
        case setLoadingState(LoadingState)
        case fetchServers
        case serversFetched([Server])
        case fetchFailed
    }

    @Dependency(\.serverProvider) private var serversProvider

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.fetchServers)

            case .didTapFilterButton:
                return .none

            case .didTapLogoutButton:
                return .none

            case .fetchServers:
                return .concatenate(
                    .send(.setLoadingState(.loading)),
                    loadServers(),
                    .send(.setLoadingState(.loaded))
                )

            case .serversFetched(let servers):
                state.servers = IdentifiedArrayOf(uniqueElements: servers)
                return .none
                
            case .fetchFailed:
                return .none

            case .setLoadingState(let loadingState):
                state.loadingState = loadingState
                return .none
            }
        }
        ._printChanges()
    }
}

private extension ServersList {
    func loadServers() -> Effect<Action> {
        .run { send in
            do {
                let servers = try await serversProvider.servers()
                await send(.serversFetched(servers))
            } catch {
                await send(.fetchFailed)
            }
        }
    }
}
