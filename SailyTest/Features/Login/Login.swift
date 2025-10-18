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
        case binding(BindingAction<State>)
    }

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in

            switch action {
            case .didTapOutsideTextfield:
                state.focus = .none
                return .none
            case .didTapLoginButton:
                return .none
            case .binding(_):
                return .none
            }
        }
        ._printChanges()
    }
}
