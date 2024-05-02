//
//  NifflerTests.swift
//  NifflerTests
//
//  Created by Mikhail Rubanov on 17.11.2023.
//

import XCTest
@testable import Api

final class ApiTests: XCTestCase {
    
    var network: Api!
    
    override func setUpWithError() throws {
        network = Api()
    }

    override func tearDownWithError() throws {
        network = nil
    }

    func test_unauthorizedSession() async throws {
        let request = network.request(method: "GET", path: "session")

        let (text, response) = try await network.performWithStringResult(request)
        
        XCTAssertEqual(text, "{\"type\":\"about:blank\",\"title\":\"Not Found\",\"status\":404,\"detail\":\"No static resource session.\",\"instance\":\"/session\"}")
        XCTAssertEqual(response.statusCode, 404)
    }
    
    func test_unauthorized_currentUser() async throws {
        let request = network.request(method: "GET", path: "currentUser")
        
        let (text, response) = try await network.performWithStringResult(request)
        
        XCTAssertEqual(text, "{\"type\":\"about:blank\",\"title\":\"Not Found\",\"status\":404,\"detail\":\"No static resource currentUser.\",\"instance\":\"/currentUser\"}")
        XCTAssertEqual(response.statusCode, 404)
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
            category: "Рыбалка",
            currency: "RUB",
            amount: 69,
            description: "Test Spend",
            username: "stage"
        )

        let (spend, response) = try await network.addSpend(testSpend)
        
        XCTAssertEqual(response.statusCode, 201)
        XCTAssertEqual(spend.category, testSpend.category)
    }
    
    /// Stub wrong auth header
    /// Request spends -> 401
    /// Login -> Retry
    /// -> Response
    func test_whenReceive401_andPassLogin_shouldRetryRequest() async throws {
        // Arrange
        UserDefaults.standard.set("explicitly wrong token", forKey: "UserAuthToken")
        let showLoginUIExpectation = expectation(description: "show UI")
        network.auth.requestCredentialsFromUser = {
            showLoginUIExpectation.fulfill()
            
            Task {
                do {
                    try await self.network.auth.authorize(user: "stage",
                                                          password: "12345")
                } catch let error {
                    // TODO: Fail test if authorize has failed
//                    XCTFail("Wrong credentials")
                }
            }
        }
        
        // Act
        let (spends, response) = try await network.getSpends()
        
        // Asser
        await fulfillment(of: [showLoginUIExpectation], timeout: 1)
        
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertTrue(spends.content.count > 0)
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
