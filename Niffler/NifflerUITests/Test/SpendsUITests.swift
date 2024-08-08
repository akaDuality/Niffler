import XCTest

final class SpendsUITests: TestCase {
    
    func test_whenAddSpent_shouldShowSpendInList() {
        launchAppWithoutLogin()
        
        // Arrange
        loginPage
            .input(login: "stage", password: "12345")
        
        // Act
        spendsPage
            .waitSpendsScreen()
            .addSpent()
        
        let title = UUID().uuidString
        newSpendPage
            .inputSpent(title: title)
        
        // Assert
        spendsPage
            .assertNewSpendIsShown(title: title)
    }
}
