import Foundation
import XCTest

class LoginScreen: BaseScreen {
    private var userNameTextField: XCUIElement {
        app.textFields[LoginViewIDs.userNameTextField.rawValue].firstMatch
    }
    private var passwordTextField: XCUIElement {
        app.secureTextFields[LoginViewIDs.passwordTextField.rawValue].firstMatch
    }
    
    private var loginButton: XCUIElement {
        app.buttons[LoginViewIDs.loginButton.rawValue].firstMatch
    }
    
    func login(login: String = "stage", password: String = "12345") {
        XCTAssert(userNameTextField.waitForExistence(timeout: 3))
        userNameTextField.tap()
        userNameTextField.typeText(login)
        passwordTextField.tap()
        passwordTextField.typeText(password)
        loginButton.tap()
    }

    func assertLoginButton() {
        XCTAssert(loginButton.waitForExistence(timeout: 3))
    }
}
