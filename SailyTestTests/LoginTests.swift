//
//  LoginTests.swift
//  SailyTestTests
//
//  Created by Vitalii Kizlov on 18.10.2025.
//

import XCTest
import ComposableArchitecture
@testable import SailyTest

@MainActor
final class LoginTests: XCTestCase {
    
    // MARK: - Test Store Setup
    
    private func makeTestStore(
        initialState: Login.State = Login.State(),
        tokenProvider: TokenProvider = .mock,
        keychainClient: KeychainClient = .mock
    ) -> TestStore<Login.State, Login.Action> {
        let store = TestStore(initialState: initialState) {
            Login()
        } withDependencies: {
            $0.tokenProvider = tokenProvider
            $0.keychainClient = keychainClient
            $0.mainQueue = .immediate
        }

        store.exhaustivity = .off
        return store
    }
    
    // MARK: - 1. Initial State Tests
    
    func testInitialState() {
        let store = makeTestStore()
        
        XCTAssertEqual(store.state.username, "")
        XCTAssertEqual(store.state.password, "")
        XCTAssertEqual(store.state.focus, nil)
        XCTAssertEqual(store.state.isLoading, false)
        XCTAssertEqual(store.state.alert, nil)
    }
    
    // MARK: - 2. User Input Tests
    
    func testUsernameInput() async {
        let store = makeTestStore()
        
        await store.send(.binding(.set(\.username, "testuser"))) {
            $0.username = "testuser"
        }
    }
    
    func testPasswordInput() async {
        let store = makeTestStore()
        
        await store.send(.binding(.set(\.password, "testpass"))) {
            $0.password = "testpass"
        }
    }
    
    func testFocusManagement() async {
        let store = makeTestStore()
        
        await store.send(.binding(.set(\.focus, .username))) {
            $0.focus = .username
        }
        
        await store.send(.binding(.set(\.focus, .password))) {
            $0.focus = .password
        }
    }
    
    func testTapOutsideClearsFocus() async {
        let store = makeTestStore(initialState: Login.State(focus: .username))
        
        await store.send(.didTapOutsideTextfield) {
            $0.focus = nil
        }
    }
    
    // MARK: - 3. Form Validation Tests
    
    func testEmptyFormValidation() {
        let store = makeTestStore()
        
        XCTAssertFalse(store.state.isFormValid)
    }
    
    func testPartialFormValidation_OnlyUsername() {
        let store = makeTestStore(initialState: Login.State(username: "testuser"))
        
        XCTAssertFalse(store.state.isFormValid)
    }
    
    func testPartialFormValidation_OnlyPassword() {
        let store = makeTestStore(initialState: Login.State(password: "testpass"))
        
        XCTAssertFalse(store.state.isFormValid)
    }
    
    func testCompleteFormValidation() {
        let store = makeTestStore(initialState: Login.State(
            username: "testuser",
            password: "testpass"
        ))
        
        XCTAssertTrue(store.state.isFormValid)
    }
    
    // MARK: - 4. Login Action Tests
    
    func testLoginButtonTap() async {
        let store = makeTestStore(initialState: Login.State(
            focus: .username,
            username: "testuser",
            password: "testpass"
        ))
        
        await store.send(.didTapLoginButton) {
            $0.focus = nil
            $0.isLoading = true
        }
    }
    
    // MARK: - 5. API Integration Tests
    
    func testSuccessfulLogin() async {
        let store = makeTestStore(initialState: Login.State(
            username: "testuser",
            password: "testpass"
        ))
        
        await store.send(.didTapLoginButton) {
            $0.focus = nil
            $0.isLoading = true
        }
        
        await store.receive(.loginSucceeded(Token.mock)) {
            $0.isLoading = false
        }
    }
    
    func testFailedLogin() async {        
        let store = makeTestStore(
            initialState: Login.State(
                username: "testuser",
                password: "wrongpass"
            ),
            tokenProvider: .failing
        )
        
        await store.send(.didTapLoginButton) {
            $0.focus = nil
            $0.isLoading = true
        }
        
        await store.receive(.loginFailed) {
            $0.isLoading = false
            $0.alert = AlertState(
                title: { TextState("Verification failed") },
                message: { TextState("Your username or password is incorrect.") }
            )
        }
    }
    
    // MARK: - 6. Alert Tests
    
    func testAlertDismiss() async {
        let store = makeTestStore(initialState: Login.State(
            alert: AlertState(
                title: { TextState("Test Alert") },
                message: { TextState("Test Message") }
            )
        ))
        
        await store.send(.alert(.dismiss)) {
            $0.alert = nil
        }
    }
}
