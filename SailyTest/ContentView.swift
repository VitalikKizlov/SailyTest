//
//  ContentView.swift
//  SailyTest
//
//  Created by Vitalii Kizlov on 18.10.2025.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    var body: some View {
        LoginView(
            store: .init(
                initialState: Login.State(),
                reducer: {
                    Login()
                }
            )
        )
    }
}

#Preview {
    ContentView()
}
