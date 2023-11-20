//
//  Network.swift
//  NifflerTests
//
//  Created by Mikhail Rubanov on 17.11.2023.
//

import Foundation

class Api: Network {
    private let base = URL(string: "https://api.niffler-stage.qa.guru")!
    
    func request(method: String, path: String) -> URLRequest {
        let url = base.appendingPathComponent(path)
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "accept")
        
        return request
    }
}

class Network {
    private let urlSession = URLSession.shared
    
    func perform(_ request: URLRequest) async throws -> (String, HTTPURLResponse) {
        let (data, response) = try await urlSession.data(for: request)
        
        let text = String(data: data, encoding: .utf8)!
        
        let urlResponse = response as! HTTPURLResponse
        
        return (text, urlResponse)
    }
}

class Auth: Network {
    let base = URL(string: "https://auth.niffler-stage.qa.guru")!
    
    func request(
        method: String,
        path: String,
        query: [URLQueryItem] = []
    ) -> URLRequest {
        let url = base
            .appendingPathComponent(path)
            .appending(queryItems: query)
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "accept")
        
        return request
    }
    
    /// GET http://127.0.0.1:9000/oauth2/authorize?
    /// response_type=code&
    /// client_id=client&
    /// scope=openid&
    /// redirect_uri=http://127.0.0.1:3000/authorized&code_challenge=qPet2YMtOg9kueZraRTOsJiXNXBXuRsYDk8FS8UIK6k&code_challenge_method=S256
    func authorizeRequest() -> URLRequest {
        let request = request(
            method: "GET",
            path: "authorize",
            query: [URLQueryItem(name: "response_type", value: "code"),
                    URLQueryItem(name: "client_id", value: "client"),
                    URLQueryItem(name: "scope", value: "openid"),
                    URLQueryItem(name: "redirect_uri", value: "http://127.0.0.1:3000/authorized&code_challenge=qPet2YMtOg9kueZraRTOsJiXNXBXuRsYDk8FS8UIK6k&code_challenge_method=S256"),
                   ])
        
        return request
    }
}

