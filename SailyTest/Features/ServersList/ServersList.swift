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
    @ObservableState
    struct State: Equatable {
        var isLoading: Bool = false
    }

    enum Action: Equatable {

    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                
            }
        }
        ._printChanges()
    }
}

private extension ServersList {

}
