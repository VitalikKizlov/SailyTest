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
        NavigationStack {
            VStack(spacing: 0) {
                header()

                // TODO: - add zstack with animation
                // add separate loading view with image background and spinner
                if store.loadingState == .loading {
                    LoadingView()
                } else {
                    serversList()
                }
            }
            .navigationBarTitle("Testio.", displayMode: .inline)
            .navigationBarItems(leading: sortButton(), trailing: logoutButton())
            .toolbarBackground(Color.white, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                store.send(.onAppear)
            }
            .confirmationDialog(
                $store.scope(
                    state: \.confirmationDialog,
                    action: \.confirmationDialog
                )
            )
        }
    }
}

private extension ServersListView {
    func sortButton() -> some View {
        Button {
            store.send(.didTapFilterButton)
        } label: {
            HStack(spacing: 4) {
                Image("sortIcon")
                Text("Filter")
                    .font(.system(size: 17, weight: .regular))
            }
        }
    }

    func logoutButton() -> some View {
        Button {
            store.send(.didTapLogoutButton)
        } label: {
            HStack(spacing: 4) {
                Text("Logout")
                    .font(.system(size: 17, weight: .regular))
                Image("logoutIcon")
            }
        }
    }

    func header() -> some View {
        HStack {
            Text("SERVER")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.headerTitle)
            Spacer()
            Text("DISTANCE")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.headerTitle)
        }
        .padding(.horizontal, 16)
        .padding(.top, 24)
        .padding(.bottom, 8)
        .background(Color.headerBackground)
    }

    func serversList() -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(store.servers.enumerated()), id: \.element.id) { index, item in
                    ServerRowView(server: item)
                        .contentShape(Rectangle())
                        .overlay(alignment: .bottom) {
                            if index != store.servers.count - 1 {
                                separator()
                            }
                        }
                }
            }
        }
        .scrollIndicators(.hidden)
    }

    func separator() -> some View {
        Divider()
            .overlay(Color.gray)
            .padding(.leading)
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
