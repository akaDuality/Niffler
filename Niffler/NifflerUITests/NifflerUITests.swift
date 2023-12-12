//
//  NifflerUITests.swift
//  NifflerUITests
//
//  Created by Mikhail Rubanov on 21.11.2023.
//

import XCTest

final class NifflerUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        UserDefaults.standard.unauthorize()
    }

    override func tearDownWithError() throws {
    }

    func testUnathorizeLaunch() throws {
        app.launch()

        LoginScreen().assertLoginButton()
    }

    func testFirstSuccessLogin() throws {
        app.launch()

        LoginScreen().login()
        SpendsScreen().assertSpendScreen()
    }
}

// TODO: Move key to some shared library
public extension UserDefaults {
    func unauthorize() {
        UserDefaults.standard.removeObject(forKey: "UserAuthToken")
    }
}
