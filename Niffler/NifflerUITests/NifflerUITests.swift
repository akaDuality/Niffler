//
//  NifflerUITests.swift
//  NifflerUITests
//
//  Created by Mikhail Rubanov on 30.04.2024.
//

import XCTest

final class NifflerUITests: XCTestCase {
    
    var app: XCUIApplication!

    func test_loginSuccess() throws {
        // Arrange
        launchAppWithoutLogin()
        
        // Act
        input(login: "stage", password: "12345")
        
        // Assert
        assertIsSpendsViewAppeared()
    }
    
    func test_loginFailure() throws {
        // Arrange
        launchAppWithoutLogin()
        
        // Act
        input(login: "stage", password: "1")
        
        // Assert
        assertIsLoginErrorShown()
    }
    
    func test_whenAddSpent_shouldShowSpendInList() {
        // Arrange
        launchAppWithoutLogin()
        input(login: "stage", password: "12345")
        waitSpendsScreen()
        
        // Act
        addSpent()
        inputAmount()
        selectCategory()
        let title = UUID().uuidString
        inputDescription(title)
        swipeToAddSpendsButton()
        pressAddSpend()
        
        // Assert
        assertNewSpendIsShown(title: title)
    }
    
//    func test_whenAddSpent_shouldShowSpendInList() {
//        // Arrange
//        launchAppWithoutLogin()
//        
//        // TODO: About test data
//        LoginScreen()
//            .inputAndWait(user: .stage)
//        
//        // Act
//        let title = UUID().uuidString
//        SpendScreen()
//            .addSpent(
//                title: title,
//                amount: 16,
//                category: "Рыбалка"
//            )
//        
//        // Assert
//        assertNewSpendIsShown(title: title)
//    }
    
    // MARK: - Domain Specific Language
    // MARK: Spends List
    func addSpent() {
        app.buttons["addSpendButton"].tap()
    }
    
    func assertNewSpendIsShown(title: String, file: StaticString = #filePath, line: UInt = #line) {
        let isFound = app.scrollViews.switches.staticTexts[title].waitForExistence(timeout: 1)
        XCTAssertTrue(isFound, file: file, line: line)
    }
    
    // MARK: New spend
    func inputAmount() {
        app.textFields["amountField"].typeText("14")
    }
    
    func selectCategory() {
        app.buttons["Select category"].tap()
        app.buttons["Рыбалка"].tap() // TODO: Bug
    }
    
    fileprivate func inputDescription(_ title: String) {
        app.textFields["descriptionField"].tap()
        app.textFields["descriptionField"].typeText(title)
    }
    
    fileprivate func swipeToAddSpendsButton() {
        let screenCenter = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let screenTop = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.15))
        screenCenter.press(forDuration: 0.01, thenDragTo: screenTop)
    }
    
    fileprivate func pressAddSpend() {
        app.buttons["Add Spend"].tap()
    }
    
    // MARK: Login
    private func launchAppWithoutLogin() {
        XCTContext.runActivity(named: "Запускаю приложение в режиме 'без авторизации'") { _ in
            app = XCUIApplication()
            app.launchArguments = ["RemoveAuthOnStart"]
            app.launch()
        }
    }
    
    private func input(login: String, password: String) {
        input(login: login)
        input(password: password)
        pressLoginButton()
    }
    
    private func input(login: String) {
        XCTContext.runActivity(named: "Ввожу логин \(login)") { _ in
            app.textFields["userNameTextField"].tap()
            app.textFields["userNameTextField"].typeText(login)
        }
    }
    
    private func input(password: String) {
        XCTContext.runActivity(named: "Ввожу пароль \(password)") { _ in
            app.secureTextFields["passwordTextField"].tap()
            app.secureTextFields["passwordTextField"].typeText(password)
        }
    }
    
    private func pressLoginButton() {
        XCTContext.runActivity(named: "Жму кнопку логина") { _ in
            app.buttons["loginButton"].tap()
        }
    }
    
    fileprivate func waitSpendsScreen(file: StaticString = #filePath, line: UInt = #line) {
        let isFound = app.scrollViews.switches.firstMatch.waitForExistence(timeout: 10)
        
        XCTAssertTrue(isFound,
                      "Не дождались экрана со списком трат",
                      file: file, line: line)
    }
    
    func assertIsSpendsViewAppeared() {
        XCTContext.runActivity(named: "Жду экран с тратами") { _ in
            waitSpendsScreen()
            XCTAssertGreaterThanOrEqual(app.scrollViews.switches.count, 1)
        }
    }
    
    func assertIsLoginErrorShown(file: StaticString = #filePath, line: UInt = #line) {
        XCTContext.runActivity(named: "Жду сообщение с ошибкой") { _ in
            let isFound = app.staticTexts["Нет такого пользователя. Попробуйте другие данные"].waitForExistence(timeout: 5)
            XCTAssertTrue(isFound,
                          "Не нашли сообщение о неправильном логине",
                          file: file, line: line)
        }
    }
}
