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
    
    enum SortOption: Equatable {
        case distance
        case alphabetical
    }

    @ObservableState
    struct State: Equatable {
        var loadingState: LoadingState = .idle
        var servers: IdentifiedArrayOf<Server> = []

        @Presents var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?
    }

    enum Action: Equatable {
        case onAppear
        case didTapFilterButton
        case didTapLogoutButton
        case setLoadingState(LoadingState)
        case fetchServers
        case serversFetched([Server])
        case fetchFailed

        case confirmationDialog(PresentationAction<ConfirmationDialog>)

        enum ConfirmationDialog: Equatable {
            case dismiss
            case sortByDistance
            case sortAlphabetically
        }
    }

    @Dependency(\.serverProvider) private var serversProvider
    @Dependency(\.keychainClient) private var keychainClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.fetchServers)

            case .didTapFilterButton:
                return showConfirmationDialog(&state)

            case .didTapLogoutButton:
                return .run { _ in
                    try keychainClient.clearAll()
                }

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

            // MARK: - ConfirmationDialog actions
            case .confirmationDialog(.presented(let presentedAction)):
                switch presentedAction {
                case .dismiss:
                    return .none
                case .sortByDistance:
                    state.servers = sortServers(state.servers, by: .distance)
                    return .none
                case .sortAlphabetically:
                    state.servers = sortServers(state.servers, by: .alphabetical)
                    return .none
                }
            case .confirmationDialog(.dismiss):
                return .none
            }
        }
        .ifLet(\.$confirmationDialog, action: \.confirmationDialog)
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
    
    func sortServers(_ servers: IdentifiedArrayOf<Server>, by option: SortOption) -> IdentifiedArrayOf<Server> {
        switch option {
        case .distance:
            return IdentifiedArrayOf(uniqueElements: servers.sorted { $0.distance < $1.distance })
        case .alphabetical:
            return IdentifiedArrayOf(uniqueElements: servers.sorted { $0.name < $1.name })
        }
    }

    func showConfirmationDialog(_ state: inout State) -> Effect<Action> {
        state.confirmationDialog = ConfirmationDialogState {
            TextState("Sort by")
        } actions: {
            ButtonState(action: .sortByDistance) {
                TextState("By distance")
            }
            ButtonState(action: .sortAlphabetically) {
                TextState("Alphabetical")
            }
        }
        return .none
    }
}
