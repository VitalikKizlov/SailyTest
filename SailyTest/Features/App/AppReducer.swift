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

    enum Action: Equatable {
        case onAppear
        case contentMode(ContentModeAction)

        @CasePathable
        enum ContentModeAction: Equatable {
            case login(Login.Action)
            case serversList(ServersList.Action)
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
                
            case .contentMode(let contentModeAction):
                switch contentModeAction {
                case .login(let loginAction):
                    return .none

                case .serversList(let serverListAction):
                    return .none
                }
            }
        }
    }
}
