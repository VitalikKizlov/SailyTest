//
//  AppReducer.swift
//  SailyTest
//
//  Created by Vitalii Kizlov on 18.10.2025.
//

import Foundation
import ComposableArchitecture

@Reducer
struct AppReducer {
    @ObservableState
    struct State: Equatable {
        @CasePathable
        @dynamicMemberLookup
        enum ContentMode: Equatable {
            case login(Login.State)
            case serversList(ServersList.State)
        }

        var contentMode: ContentMode = .login(Login.State())
    }

    enum Action: BindableAction, Equatable {
        case onAppear
        case checkCredentials
        case credentialsFound
        case credentialsNotFound
        case authFailed
        case contentMode(ContentModeAction)
        case binding(BindingAction<State>)

        @CasePathable
        enum ContentModeAction: Equatable {
            case login(Login.Action)
            case serversList(ServersList.Action)
        }
    }
    
    @Dependency(\.keychainClient) private var keychainClient

    var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.checkCredentials)
                
            case .checkCredentials:
                return checkCredentials()
                
            case .credentialsFound:
                state.contentMode = .serversList(ServersList.State())
                return .none
                
            case .credentialsNotFound:
                state.contentMode = .login(Login.State())
                return .none
                
            case .authFailed:
                state.contentMode = .login(Login.State())
                return .run { _ in
                    try keychainClient.clearAll()
                }
                
            case .contentMode(let contentModeAction):
                switch contentModeAction {
                case .login(let loginAction):
                    switch loginAction {
                    case .loginSucceeded:
                        state.contentMode = .serversList(ServersList.State())
                        return .none
                    default:
                        return .none
                    }

                case .serversList(let serverListAction):
                    switch serverListAction {
                    case .didTapLogoutButton:
                        state.contentMode = .login(Login.State())
                        return .none
                    case .authFailed:
                        return .send(.authFailed)
                    default:
                        return .none
                    }
                }
                
            case .binding:
                return .none
            }
        }
        .ifLet(\.contentMode.login, action: \.contentMode.login) {
            Login()
        }
        .ifLet(\.contentMode.serversList, action: \.contentMode.serversList) {
            ServersList()
        }
    }
}

private extension AppReducer {
    func checkCredentials() -> Effect<Action> {
        .run { send in
            do {
                _ = try keychainClient.getCredentials()
                await send(.credentialsFound)
            } catch {
                await send(.credentialsNotFound)
            }
        }
    }
}
