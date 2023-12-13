import Foundation
import XCTest

class SpendsScreen: BaseScreen {
    private var spendsList: XCUIElement {
        app.collectionViews[SpendsViewIDs.spendsList.rawValue].firstMatch
    }
    
    private var addSpendButton: XCUIElement {
        app.buttons[SpendsViewIDs.addSpendButton.rawValue].firstMatch
    }
    
    func assertSpendScreen() {
        XCTAssert(addSpendButton.waitForExistence(timeout: 10))
        XCTAssert(addSpendButton.isHittable)
    }
}
