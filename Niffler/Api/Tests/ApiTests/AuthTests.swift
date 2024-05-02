//
//  NifflerTests.swift
//  NifflerTests
//
//  Created by Mikhail Rubanov on 17.11.2023.
//

import XCTest
@testable import Api

final class AuthTests: XCTestCase {
    
    var network: Auth!
    
    override func setUpWithError() throws {
        network = Auth()
    }

    override func tearDownWithError() throws {
        network = nil
    }
    
    func test_url() {
        let network = Auth(challenge: "QNnEmCn1HQjPuEZJ0ABU866WYYoLTbkq46p6c4I0BHU")
        
        let requestURL = network.authorizeRequest().url
        
        let result = URL(string:
    "https://auth.niffler-stage.qa.guru/oauth2/authorize?response_type=code&client_id=client&scope=openid&redirect_uri=https://niffler-stage.qa.guru/authorized&code_challenge=QNnEmCn1HQjPuEZJ0ABU866WYYoLTbkq46p6c4I0BHU&code_challenge_method=S256")
        
        XCTAssertEqual(requestURL, result)
    }

    func test_auth() async throws {
        try await network.authorize(user: "Misha1",
                                    password: "123")
        
        XCTAssertNotNil(network.authorizationHeader)
    }
    
    // TODO: Узнать зачем этот endpoint
    func test_registerAndAuthorize() async throws {
        let username = UUID().uuidString
        
        let response = try await network.register(username: username,
                                                  password: "123")
        XCTAssertEqual(response, 201)
        
        try await network.authorize(user: username,
                                    password: "123")
        XCTAssertNotNil(network.authorizationHeader)
    }
    
    func test_logout() async throws {
        try await network.authorize(user: "stage",
                                    password: "12345")
        
        try await network.logout()
        
        try await network.authorize(user: "stage",
                                    password: "12345")
        
        XCTAssertNotNil(network.authorizationHeader)
    }
    
    
    
    // TODO: Logout on 401 error
    // TODO: Refresh token after 401 automatically. Waiting for backend implementation
}
