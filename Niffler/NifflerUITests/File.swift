//class Test {
//    func test_whenAddSpent_shouldShowSpendInList() {
//        // Arrange
//        launchAppWithoutLogin()
//        
//        // TODO: About test data
//        loginScreen
//            .inputAndWait(user: .stage)
//        
//        // Act
//        spendsScreen
//            .addSpent()
//        
//        let title = UUID().uuidString
//        newSpendScreen
//            .inputAmount()
//            .selectCategory()
//            .inputDescription(title)
//            .swipeToAddSpendsButton()
//            .pressAddSpend()
//        
//        // Assert
//        spendsScreen
//            .assertNewSpendIsShown(title: title)
//    }
//    
//    func test_whenAddSpent_shouldShowSpendInList() {
//        // Arrange
//        launchAppWithoutLogin()
//        
//        // TODO: About test data
//        loginScreen
//            .inputAndWait(user: .stage)
//        
//        // Act
//        let title = UUID().uuidString
//        spendsScreen
//            .addSpent(
//                title: title,
//                amount: 16,
//                category: "Рыбалка"
//            )
//        
//        // Assert
//        spendsScreen
//            .assertNewSpendIsShown(title: title)
//    }
//}
