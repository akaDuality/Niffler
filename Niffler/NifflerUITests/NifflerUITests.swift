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
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
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
