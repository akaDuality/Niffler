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
    
    func test_unauthorized_whenGetCurrentUser_shouldFail() async throws {
        let request = network.request(method: "GET", path: "currentUser")
        
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
    
    func test_authorized_spends() async throws {
        try await network.auth.authorize(user: "stage", password: "12345")

        let (spends, response) = try await network.getSpends()
        
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertTrue(spends.content.count > 0)
    }
    
    func test_add_spend() async throws {
        try await network.auth.authorize(user: "stage", password: "12345")
        
        let testSpend = Spends(
            id: "Any",
            spendDate: DateFormatterHelper.shared.dateFormatterToApi.date(from: "2023-12-07T05:00:00.000+00:00"),
            category: CategoryDTO(name: "Test", archived: false),
            currency: "RUB",
            amount: 69,
            description: "Test Spend",
            username: "stage"
        )

        let (spend, response) = try await network.addSpend(testSpend)
        
        XCTAssertEqual(response.statusCode, 201)
        XCTAssertEqual(spend.description, testSpend.description)
    }
    
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
    
    // MARK: - Concurrency
    func test_notAuthorized_whenPerformTwoRequests_shouldPresentLoginUIOnce() async throws {
        // Not authorized
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
    
    // MARK: flow with bearer token
    
    // MARK: Spends
//    @GetMapping("/spends") - все мои траты
//    @PostMapping("/addSpend") - добавляем новую трату
//    @PatchMapping("/editSpend") - редактируем трату
//    @DeleteMapping("/deleteSpends") - удаляем трату
//    @GetMapping("/statistic") - статистика по всем тратам в текущей валюте юзера
//    @GetMapping("/categories") - список существующих категорий трат
//    @PostMapping("/category") - добавление новой категории (не более 8 для пользователя)
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
}
