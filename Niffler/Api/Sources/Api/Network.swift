//
//  Network.swift
//  NifflerTests
//
//  Created by Mikhail Rubanov on 17.11.2023.
//

import Foundation

class Api: Network {
    private let base = URL(string: "https://api.niffler-stage.qa.guru")!
    let auth = Auth()
    
    func request(method: String, path: String) -> URLRequest {
        let url = base.appendingPathComponent(path)
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "accept")
        
        if let authorization = auth.authorizationHeader {
            request.addValue(
                authorization,
                forHTTPHeaderField: "Authorization")
        }
        return request
    }
}

class Network: NSObject {
    private lazy var urlSession: URLSession = .shared
    
    func performWithStringResult(_ request: URLRequest) async throws -> (String, HTTPURLResponse) {
        
        let (data, response) = try await perform(request)
        
        let text = String(data: data, encoding: .utf8)!
        
        return (text, response)
    }
    
    func perform(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        print("Manually call \(request.httpMethod!) \(request.url!))")
        let (data, response) = try await urlSession.data(for: request)
        
        let urlResponse = response as! HTTPURLResponse
        
        print("Did receive in the end \(urlResponse.url!)")
        return (data, urlResponse)
    }
}
