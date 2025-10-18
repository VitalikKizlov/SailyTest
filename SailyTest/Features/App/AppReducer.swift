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
        case contentMode(ContentModeAction)

        @CasePathable
        enum ContentModeAction: Equatable {
            case login(Login.Action)
            case serversList(ServersList.Action)
        }
    }
}
