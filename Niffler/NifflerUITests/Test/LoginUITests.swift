import XCTest

final class LoginUITests: TestCase {
    
    func test_loginSuccess() throws {
        launchAppWithoutLogin()

        // Act
        loginPage.input(login: "stage", password: "12345")
        
        // Assert
        spendsPage.assertIsSpendsViewAppeared()
        loginPage.assertNoErrorShown()
    }
    
    func test_loginFailure() throws {
        launchAppWithoutLogin()
        
        loginPage
            .input(login: "stage", password: "1")
            .assertIsLoginErrorShown()
    }
}
