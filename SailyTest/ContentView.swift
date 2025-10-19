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
        AppView(
            store: .init(
                initialState: AppReducer.State(),
                reducer: {
                    AppReducer()
                }
            )
        )
    }
}

#Preview {
    ContentView()
}
