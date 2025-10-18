//
//  ServersListView.swift
//  SailyTest
//
//  Created by Vitalii Kizlov on 18.10.2025.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct ServersListView: View {

    @Bindable var store: StoreOf<ServersList>

    var body: some View {
        NavigationView {
            List {
                Section(header: ListHeaderView()) {
                    ForEach(store.servers) { server in
                        ServerRowView(server: server)
                    }
                }
            }
            .navigationBarTitle("Testio.", displayMode: .inline)
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(GroupedListStyle())
            .navigationBarItems(leading: sortButton(), trailing: logoutButton())
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}

private extension ServersListView {
    func sortButton() -> some View {
        Button {
            store.send(.didTapFilterButton)
        } label: {
            HStack {
                Image("sortIcon")
                Text("Filter")
            }
        }
    }

    func logoutButton() -> some View {
        Button {
            store.send(.didTapLogoutButton)
        } label: {
            HStack {
                Text("Logout")
                Image("logoutIcon")
            }
        }
    }
}

struct ListHeaderView: View {
    var body: some View {
        HStack {
            Text("SERVER")
                .foregroundColor(.headerTitle)
            Spacer()
            Text("DISTANCE")
                .foregroundColor(.headerTitle)
        }
        .padding(.horizontal)
    }
}

struct ServerRowView: View {

    let server: Server

    var body: some View {
        HStack {
            Text(server.name)
            Spacer()
            Text("\(server.distance)")
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    ServersListView(
        store: .init(
            initialState: ServersList.State(),
            reducer: {
                ServersList()
            }
        )
    )
}
