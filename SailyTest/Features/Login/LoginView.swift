//
//  LoginView.swift
//  SailyTest
//
//  Created by Vitalii Kizlov on 18.10.2025.
//

import Foundation
import SwiftUI
import ComposableArchitecture

extension Login.State {
    var usernameImageColor: Color {
        focus == .username ? .lightGrey : .lightGrey.opacity(0.6)
    }
    
    var passwordImageColor: Color {
        focus == .password ? .lightGrey : .lightGrey.opacity(0.6)
    }
    
    var usernameImage: some View {
        Image("usernameIcon")
            .resizable()
            .renderingMode(.template)
            .frame(width: 16, height: 16, alignment: .center)
            .padding(.leading, 8)
            .foregroundColor(usernameImageColor)
    }
    
    var passwordImage: some View {
        Image("lockIcon")
            .resizable()
            .renderingMode(.template)
            .frame(width: 16, height: 16, alignment: .center)
            .padding(.leading, 8)
            .foregroundColor(passwordImageColor)
    }
}

struct LoginView: View {

    @Bindable var store: StoreOf<Login>
    @FocusState var focus: Login.Field?

    var body: some View {
        ZStack {
            background()

            VStack(spacing: 40) {
                header()

                VStack(spacing: 24) {
                    textfields()
                    loginButton()
                }
                .padding(.horizontal, 32)

                Spacer()
            }
            .padding(.top, 154)
        }
        .ignoresSafeArea(.all)
        .bind($store.focus, to: $focus)
    }
}

private extension LoginView {
    func background() -> some View {
        VStack {
            Spacer()
            Image("background")
                .resizable()
                .frame(height: UIScreen.main.bounds.height / 1.75)
        }
    }

    func header() -> some View {
        HStack(alignment: .bottom, spacing: 4) {
            Image("testio")
                .resizable()
                .frame(width: 170, height: 48)
            Circle()
                .foregroundColor(.green)
                .frame(width: 12, height: 12)
        }
    }

    var rectangle: some View {
        RoundedRectangle(cornerRadius: 10)
            .frame(height: 40)
            .foregroundColor(.fieldBackground).opacity(0.12)
    }


    func textfields() -> some View {
        VStack(spacing: 16) {
            rectangle
                .overlay(
                    HStack(spacing: 9) {
                        store.state.usernameImage

                        TextField("Username ", text: $store.state.username)
                            .focused($focus, equals: .username)
                            .font(.system(size: 17, weight: .regular))
                            .autocapitalization(.none)
                    }
                )

            rectangle
                .overlay(
                    HStack(spacing: 9) {
                        store.state.passwordImage

                        SecureField("Password", text: $store.state.password)
                            .focused($focus, equals: .password)
                            .font(.system(size: 17, weight: .regular))
                    }
                )
        }
    }

    func loginButton() -> some View {
        VStack {

        }
    }
}

#Preview {
    LoginView(
        store: .init(
            initialState: Login.State(),
            reducer: {
                Login()
            }
        )
    )
}
