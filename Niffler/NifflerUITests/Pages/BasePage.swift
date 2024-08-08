import XCTest

class BasePage {
    init(app: XCUIApplication) {
        self.app = app
    }
    
    let app: XCUIApplication
}
