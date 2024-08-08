import XCTest

class SpendsPage: BasePage {
    func assertIsSpendsViewAppeared() {
        XCTContext.runActivity(named: "Жду экран с тратами") { _ in
            waitSpendsScreen()
            XCTAssertGreaterThanOrEqual(app.scrollViews.switches.count, 1)
        }
    }
    
    @discardableResult
    func waitSpendsScreen(file: StaticString = #filePath, line: UInt = #line) -> Self {
        let isFound = app.scrollViews.switches.firstMatch.waitForExistence(timeout: 10)
        
        XCTAssertTrue(isFound,
                      "Не дождались экрана со списком трат",
                      file: file, line: line)
        
        return self
    }
    
    func addSpent() {
        app.buttons["addSpendButton"].tap()
    }
    
    func assertNewSpendIsShown(title: String, file: StaticString = #filePath, line: UInt = #line) {
        let isFound = app.scrollViews.switches.staticTexts[title].waitForExistence(timeout: 1)
        XCTAssertTrue(isFound, file: file, line: line)
    }
}
