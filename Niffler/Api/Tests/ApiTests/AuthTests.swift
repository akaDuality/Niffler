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
        try await network.authorize(user: "stage", 
                                    password: "12345")
        
        XCTAssertNotNil(network.authorizationHeader)
    }
    
    // TODO: Logout on 401 error
    // TODO: Refresh token after 401 automatically. Waiting for backend implementation
}
