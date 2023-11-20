//
//  NifflerTests.swift
//  NifflerTests
//
//  Created by Mikhail Rubanov on 17.11.2023.
//

import XCTest
@testable import Niffler

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

        let (text, response) = try await network.perform(request)
        
        XCTAssertEqual(text, "{\"username\":null,\"issuedAt\":null,\"expiresAt\":null}")
        XCTAssertEqual(response.statusCode, 200)
    }
    
    func test_unauthorized_currentUser() async throws {
        let request = network.request(method: "GET", path: "currentUser")
        
        let (text, response) = try await network.perform(request)
        
        XCTAssertEqual(text, "")
        XCTAssertEqual(response.statusCode, 401)
    }
    
    private let token = "Bearer eyJraWQiOiIxYjVkNjA0MS01ZTQ0LTRmNGYtYWYyMC0zNzQxMDAyMGQ1NWMiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJha2FEdWFsaXR5QHlhbmRleC5ydSIsImF1ZCI6ImNsaWVudCIsImF6cCI6ImNsaWVudCIsImF1dGhfdGltZSI6MTcwMDIyNDAwMiwiaXNzIjoiaHR0cHM6Ly9hdXRoLm5pZmZsZXItc3RhZ2UucWEuZ3VydSIsImV4cCI6MTcwMDIyNTgwNiwiaWF0IjoxNzAwMjI0MDA2LCJzaWQiOiJjNEN1eWtXX1VmQWVaTUREZjFUN0hJckp3ZDdnNzlMaE1lNUlCQ1BlMXJVIn0.mXOqOMi-spuI4KEnsxqYnS-eaUatEjNs4OBqJddEPxXADS6Lrqamy3fOYr42Fxx9hCaTPIAYJDiW5fn_RNnbmgfVQcztiDdwYLeQpSczpwzQzwv_XVushr9Lo_1POA_VJxm6YDwctVzW2CISYEjDZhgdDJcmTMTRZW0eCuyEx9KZLNUIXw2QTtT0eE-bzwRHIAZwjl7y0wc2QV6f9D-HF8UD8qy8r_DVueO0duDkKjpRUY5ATiwN37LlBLI5cr0aNN-gOpEjyC56yLJmwlW9LWN4ZmCyCA2IPfq7GzVs10PfhDS20nXV3L-ODk32xjdBv_fqSEpduHrz5NuKL-em4g"
    
    func test_authorized_currentUser() async throws {
        var request = network.request(method: "GET", path: "currentUser")
        request.addValue(token, forHTTPHeaderField: "Authorization")
        let (text, response) = try await network.perform(request)
        
        XCTAssertEqual(text, "{\"id\":\"91c42b35-30f0-4a70-8fc7-e11d99da7702\",\"username\":\"akaDuality@yandex.ru\",\"firstname\":null,\"surname\":null,\"currency\":\"RUB\",\"photo\":null}")
        XCTAssertEqual(response.statusCode, 200)
    }

    // MARK: flow with bearer token
    
//    @Post /updateUserInfo
//    @Get /currentUser
//    @GetMapping("/categories") - список существующих категорий трат
//    @PostMapping("/category") - добавление новой категории (не более 8 для пользователя)
//    @GetMapping("/allCurrencies") - доступные валюты трат
    
    // MARK: Friends
//    @GetMapping("/friends") - мои друзья
//    @GetMapping("/invitations") - приглашения дружить
//    @PostMapping("/acceptInvitation") - принять запрос на дружбу
//    @PostMapping("/declineInvitation") - отклонить запрос на дружбу
//    @PostMapping("/addFriend") - отправить запрос на дружбу с кем-то
//    @DeleteMapping("/removeFriend") - удалить существующего друга
    
    // MARK: Spends
//    @GetMapping("/spends") - все мои траты
//    @PostMapping("/addSpend") - добавляем новую трату
//    @PatchMapping("/editSpend") - редактируем трату
//    @DeleteMapping("/deleteSpends") - удаляем трату
//    @GetMapping("/statistic") - статистика по всем тратам в текущей валюте юзера
}


//extension Network: URLSessionTaskDelegate {
//    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest) async -> URLRequest? {
//        request
//    }
//}
