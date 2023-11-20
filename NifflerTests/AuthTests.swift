//
//  NifflerTests.swift
//  NifflerTests
//
//  Created by Mikhail Rubanov on 17.11.2023.
//

import XCTest
@testable import Niffler

final class AuthTests: XCTestCase {
    
    var network: Auth!
    
    override func setUpWithError() throws {
        network = Auth()
    }

    override func tearDownWithError() throws {
        network = nil
    }

    func test_auth() async throws {
        let request = network.authorizeRequest()
        
        let (data, response) = try await network.perform(request)
        
        XCTAssertEqual(data, "")
        // итог флоу аутентификации http://127.0.0.1:3000/authorized?code=g9SfSvOnl8Ob1o_GnkH5-0ZAuKaqiHBq8MmNAqFlT-RzSLKTLUO771DePHC5SLuddooWiJyhJ5zf4_U2uD3NseMx8yAtjAEf_o6vjto2ew8JS7mJyrK-K7VK6NhWmFL2
        // Code – jwt token
        
        // POST http://127.0.0.1:9000/oauth2/token?client_id=client&redirect_uri=http://127.0.0.1:3000/authorized&grant_type=authorization_code&code=g9SfSvOnl8Ob1o_GnkH5-0ZAuKaqiHBq8MmNAqFlT-RzSLKTLUO771DePHC5SLuddooWiJyhJ5zf4_U2uD3NseMx8yAtjAEf_o6vjto2ew8JS7mJyrK-K7VK6NhWmFL2&code_verifier=3M6biEplhBEu1mLnlBB2edi2GkBKp1fDBbCWpo8RVco
        
        
//        {
//            "access_token": "eyJraWQiOCzaSQ",
//            "refresh_token": "l6KmjFNYf4aigBL",
//            "scope": "openid",
//            "id_token": "eyJraWQiOh1B5oA",    <------ bearer
//            "token_type": "Bearer",
//            "expires_in": 35999
//        }
    }
    
    // TODO: add bearer token
    // TODO: oauth flow
    
}
