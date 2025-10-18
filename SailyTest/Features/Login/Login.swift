//
//  Login.swift
//  SailyTest
//
//  Created by Vitalii Kizlov on 18.10.2025.
//

import Foundation
import ComposableArchitecture

@Reducer
struct Login {
    enum Field: Hashable {
        case username
        case password
    }

    @ObservableState
    struct State: Equatable {
        var focus: Field?
        var username: String = ""
        var password: String = ""
        var isLoading: Bool = false

        @Presents var alert: AlertState<Action.Alert>?
    }

    enum Action: BindableAction, Equatable {
        case didTapOutsideTextfield
        case didTapLoginButton
        case loginSucceeded(Token)
        case loginFailed
        case binding(BindingAction<State>)
        case alert(PresentationAction<Alert>)
        
        enum Alert: Equatable {
            case dismiss
        }
    }

    @Dependency(\.tokenProvider) private var tokenProvider
    @Dependency(\.keychainClient) private var keychainClient

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in

            switch action {
            case .didTapOutsideTextfield:
                state.focus = .none
                return .none
            case .didTapLoginButton:
                state.focus = .none
                state.isLoading = true
                let credentials = UserCredentials(name: state.username, pass: state.password)
                return performLogin(with: credentials)
            case .loginFailed:
                state.isLoading = false
                state.alert = AlertState(
                    title: {
                        TextState("Verification failed")
                    }, message: {
                        TextState("Your username or password is incorrect.")
                    }
                )
                return .none
            case .loginSucceeded(let token):
                return processSuccessLogin(with: token, state: &state)
            case .binding:
                return .none
            case .alert(.presented(.dismiss)):
                return .none
            case .alert(.dismiss):
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
        ._printChanges()
    }
}

private extension Login {
    func performLogin(with credentials: UserCredentials) -> Effect<Action> {
        .run { send in
            do {
                let token = try await tokenProvider.getToken(creds: credentials)
                debugPrint("token: \(token)")
                await send(.loginSucceeded(token))
            } catch {
                debugPrint("login operation failed with error: \(error.localizedDescription)")
                await send(.loginFailed)
            }
        }
    }

    func processSuccessLogin(with token: Token, state: inout State) -> Effect<Action> {
        state.isLoading = false
        do {
            // Store credentials and token in keychain
            try keychainClient.storeValue(state.username, .username)
            try keychainClient.storeValue(state.password, .password)
            try keychainClient.storeToken(token)
            debugPrint("✅ Credentials and token stored successfully")
        } catch {
            debugPrint("❌ Failed to store credentials: \(error.localizedDescription)")
        }
        return .none
    }
}
