import Foundation
import XCTest

class SpendsScreen: BaseScreen {
    private var spendsCollectionView: XCUIElement {
        app.collectionViews[SpendsViewIDs.spendsView.rawValue].firstMatch
    }
    
    func assertSpendScreen() {
        XCTAssert(spendsCollectionView.waitForExistence(timeout: 3))
    }
}
