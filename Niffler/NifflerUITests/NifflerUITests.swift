//
//  NifflerUITests.swift
//  NifflerUITests
//
//  Created by Mikhail Rubanov on 30.04.2024.
//

import XCTest

final class NifflerUITests: XCTestCase {

    func test_loginSuccess() throws {
        let app = XCUIApplication()
        app.launch()
        
        app.textFields["userNameTextField"].tap()
        app.textFields["userNameTextField"].typeText("stage")
        
        app.secureTextFields["passwordTextField"].tap()
        app.secureTextFields["passwordTextField"].typeText("12345")
        
        app.buttons["loginButton"].tap()
        
        let _ = app.scrollViews.switches.firstMatch.waitForExistence(timeout: 10)
        XCTAssertGreaterThanOrEqual(app.scrollViews.switches.count, 1)
    }
    
    func test_loginFailure() throws {
        let app = XCUIApplication()
        app.launch()
        
        app.textFields["userNameTextField"].tap()
        app.textFields["userNameTextField"].typeText("stage")
        
        app.secureTextFields["passwordTextField"].tap()
        app.secureTextFields["passwordTextField"].typeText("123456")
        
        app.buttons["loginButton"].tap()
        
        let _ = app.staticTexts["Нет такого пользователя. Попробуйте другие данные"].waitForExistence(timeout: 10)
    }
}
