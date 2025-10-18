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
    }

    enum Action: BindableAction, Equatable {
        case didTapOutsideTextfield
        case didTapLoginButton
        case loginSucceeded(Token)
        case loginFailed
        case binding(BindingAction<State>)
    }

    @Dependency(\.tokenProvider) private var tokenProvider

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in

            switch action {
            case .didTapOutsideTextfield:
                state.focus = .none
                return .none
            case .didTapLoginButton:
                state.focus = .none
                let credentials = UserCredentials(name: state.username, pass: state.password)
                return performLogin(with: credentials)
            case .loginFailed:
                return .none
            case .loginSucceeded(let token):
                return .none
            case .binding(_):
                return .none
            }
        }
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
}
