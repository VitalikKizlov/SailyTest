//
//  AppView.swift
//  SailyTest
//
//  Created by Vitalii Kizlov on 18.10.2025.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct AppView: View {
    @Bindable var store: StoreOf<AppReducer>

    var body: some View {
        ZStack {
            if let store = store.scope(state: \.contentMode.login, action: \.contentMode.login) {
                LoginView(store: store)
                    .transition(.opacity)
            }

            if let store = store.scope(state: \.contentMode.serversList, action: \.contentMode.serversList) {
                ServersListView(store: store)
                    .transition(.opacity)
            }
        }
    }
}
