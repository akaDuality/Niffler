//
//  NifflerTests.swift
//  NifflerTests
//
//  Created by Mikhail Rubanov on 17.11.2023.
//

import XCTest
@testable import Api

final class ApiE2ETests: XCTestCase {
    
    var network: Api!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        Auth.clearAuthorization()
        
        network = Api()
        network.auth.requestCredentialsFromUser = {
            throw TestError.shouldNotRequestInfoFromUser
        }
        
        enum TestError: Error {
            case shouldNotRequestInfoFromUser
        }
    }

    override func tearDownWithError() throws {
        network = nil
        
        Auth.clearAuthorization()
        try super.tearDownWithError()
    }

    func test_unauthorizedSession() async throws {
        let request = network.request(method: "GET", path: "session")

        let (text, response) = try await network.performWithStringResult(request)
        
        XCTAssertTrue(text.isEmpty)
        XCTAssertEqual(response.statusCode, 401)
    }
    
    func test_authorized_currentUser() async throws {
        let (name, password) = ("stage", "12345")
        
        try await network.auth.authorize(user: name, password: password)
        let (text, response) = try await network.currentUser()

        XCTAssertEqual(text.username, name)
        XCTAssertEqual(response.statusCode, 200)
    }
    
    // MARK: - Spends
    func test_authorized_getSpends_success() async throws {
        try await network.auth.authorize(user: "stage", password: "12345")

        let (spends, response) = try await network.getSpends()
        
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertTrue(spends.content.count > 0)
    }
    
    func test_authorized_addSpend_success() async throws {
        try await network.auth.authorize(user: "stage", password: "12345")
        
        let testSpend = Spends.testMake(amount: 40)
        let (spend, response) = try await network.addSpend(testSpend)
        
        XCTAssertEqual(response.statusCode, 201)
        XCTAssertEqual(spend.description, testSpend.description)
    }
    
    func test_editSpend() async throws {
        let username = UUID().uuidString.components(separatedBy: "-").first!
        try await network.auth.createUserAndLogin(username)
        
        let testSpend = Spends.testMake(amount: 40, username: username)
        let (spendResponse, _) = try await network.addSpend(testSpend)
        let editedSpend = spendResponse.with(amount: 50)
        
        let (spendAfterEditing, _) = try await network.editSpend(editedSpend)
        
        XCTAssertEqual(spendAfterEditing.amount, 50)
    }
    
    // MARK: Statistic
    
    func test_get_stat() async throws {
        try await network.auth.authorize(user: "stage", password: "12345")
        
        let (stat, response) = try await network.getStat()
        
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertTrue(stat.statByCategories.count > 0)
    }
    
    /// Stub wrong auth header
    /// Request spends -> 401
    /// Login -> Retry
    /// -> Response
    func test_whenReceive401_andPassLogin_shouldRetryRequest() async throws {
        // Arrange
        UserDefaults.standard.set("explicitly wrong token", forKey: "UserAuthToken")
        
        let showLoginUIExpectation = spyAuthUICompletion()
        
        // Act
        let (spends, response) = try await network.getSpends()
        
        // Asser
        await fulfillment(of: [showLoginUIExpectation], timeout: 1)
        
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertTrue(spends.content.count > 0)
    }
     
    private func spyAuthUICompletion() -> XCTestExpectation {
        let showLoginUIExpectation = expectation(description: "show UI")
        network.auth.requestCredentialsFromUser = {
            Task {
                defer {
                    showLoginUIExpectation.fulfill()
                }
                
                do {
                    try await self.network.auth.authorize(user: "stage", password: "12345")
                } catch {
                    XCTFail("Got error \(error)")
                }
            }
        }
        
        return showLoginUIExpectation
    }
    
    // MARK: Concurrency
    func test_notAuthorized_whenPerformTwoRequests_shouldPresentLoginUIOnce() async throws {
        Auth.removeAuth()
        spyAuthUI()
        
        try await callTwoRequestsSynchronously()
        
        XCTAssertEqual(numberOfLoginPresentations, 1)
    }
    
    private var numberOfLoginPresentations = 0
    private func spyAuthUI() {
        network.auth.requestCredentialsFromUser = { [unowned self] in
            numberOfLoginPresentations += 1
            
            Task {
                try await self.network.auth.authorize(user: "stage", password: "12345")
            }
        }
    }
    
    private func callTwoRequestsSynchronously() async throws {
        _ = try await Task {
            async let userRequest = network.currentUser()
            async let spendsRequest = network.getSpends()
            return try await [spendsRequest, userRequest] as [Any]
        }.value
    }
    
    // MARK: - Categories
    func test_getCategories() async throws {
        try await network.auth.authorize(user: "misha", password: "12345")
        
        let (categories, getResponse) = try await network.categories()
        XCTAssertEqual(getResponse.statusCode, 200)
        XCTAssertEqual(categories.count, 2)
        
        let activeCategories = categories
            .filter(\.isActive)
            .map(\.name)
        
        XCTAssertLessThanOrEqual(activeCategories.count, categories.count)
    }
    
    func test_getCategoriesRepository() async throws {
        try await network.auth.authorize(user: "misha", password: "12345")
        
        let sut = CategoriesRepository(api: network, selectedCategory: nil)
        
        try await sut.loadCategories()
        
        XCTAssertGreaterThan(sut.categories.count, 0)
    }
    
    func test_getCategoriesRepository_shouldSelectDefault() async throws {
        try await network.auth.authorize(user: "misha", password: "12345")
        
        let sut = CategoriesRepository(api: network, selectedCategory: nil)
        
        try await sut.loadCategories()
        
        XCTAssertEqual(sut.selectedCategory, "Test2")
    }
    
    func test_haveLocalDefault_getCategoriesRepository_shouldSelectLocalDefault() async throws {
        try await network.auth.authorize(user: "misha", password: "12345")
        
        let sut = CategoriesRepository(api: network, selectedCategory: "Test")
        
        try await sut.loadCategories()
        
        XCTAssertEqual(sut.selectedCategory, "Test")
    }
    
    func test_whenAddCategory_shouldSelectItAsDefault() async throws {
        try await network.auth.authorize(user: "misha", password: "12345")
        
        let sut = CategoriesRepository(api: network, selectedCategory: "Test")
        
        try await sut.loadCategories()
        sut.add("Test3")
        
        XCTAssertEqual(sut.selectedCategory, "Test3")
    }
    
    func test_newUser_whenAddCategory_shouldReturnCategoriesInGetRequest() async throws {
        let user = UUID().uuidString.components(separatedBy: "-").first!
        try await network.auth.createUserAndLogin(user)
        let category = CategoryDTO.testMake(user: user)
        
        let (_, addResponse) = try await network.addCategory(category)
        let (categories, _) = try await network.categories()
        
        XCTAssertEqual(categories.count, 1)
        XCTAssertEqual(addResponse.statusCode, 200)
    }
    
    // TODO: Test negative response
    // - {"type":"niffler-spend: Bad request","title":"Not Acceptable","status":406,"detail":"Can`t add over than 8 categories for user: 'stage'","instance":"/api/categories/add"}
    // - {"type":"niffler-spend: Bad request ","title":"Conflict","status":409,"detail":"Cannot save duplicates","instance":"/api/categories/add"}
    
    
    // MARK: Spends
//    @GetMapping("/spends") - все мои траты
//    @PostMapping("/addSpend") - добавляем новую трату
//    @PatchMapping("/editSpend") - редактируем трату
//    @DeleteMapping("/deleteSpends") - удаляем трату
//    @GetMapping("/statistic") - статистика по всем тратам в текущей валюте юзера
//    @GetMapping("/allCurrencies") - доступные валюты трат
    
    // MARK: - User
//    @Post /updateUserInfo
//    @Get /currentUser
    
    // MARK: Friends
//    @GetMapping("/friends") - мои друзья
//    @GetMapping("/invitations") - приглашения дружить
//    @PostMapping("/acceptInvitation") - принять запрос на дружбу
//    @PostMapping("/declineInvitation") - отклонить запрос на дружбу
//    @PostMapping("/addFriend") - отправить запрос на дружбу с кем-то
//    @DeleteMapping("/removeFriend") - удалить существующего друга
}

extension Auth {
    static func clearAuthorization() {
        let removeDate = Date().addingTimeInterval(-2*60*60)
        HTTPCookieStorage.shared.removeCookies(since: removeDate)
        Self.removeAuth()
    }
    
    func createUserAndLogin(_ username: String, password: String = "12345") async throws {
        try await register(username: username, password: password, passwordSubmit: password)
        try await authorize(user: username, password: password)
    }
}

extension CategoryDTO {
    static func testMake(user: String, name: String = "Test", archived: Bool = false) -> Self {
        CategoryDTO(id: UUID().uuidString, name: name,
                    username: user, archived: archived)
    }
}

extension Spends {
    static func testMake(id: String = UUID().uuidString,  amount: Double, username: String = "stage") -> Self {
        Spends(
            id: id,
            spendDate: DateFormatterHelper.shared.dateFormatterToApi.date(from: "2023-12-07T05:00:00.000+00:00")!,
            category: CategoryDTO(name: "Test", archived: false),
            currency: "RUB",
            amount: amount,
            description: "Test Spend",
            username: username
        )
    }
}

extension Spends {
    func with(amount: Double) -> Spends {
        Spends(id: id, spendDate: spendDate, category: category, currency: currency, amount: amount, description: description, username: username)
    }
}
