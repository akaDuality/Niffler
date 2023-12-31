//
//  Network.swift
//  NifflerTests
//
//  Created by Mikhail Rubanov on 17.11.2023.
//

import Foundation

public class Api: Network {
    private let base = URL(string: "https://api.niffler-stage.qa.guru")!
    public let auth = Auth()
    
    public override init() { super.init() }
    
    private let dateFormatters = DateFormatterHelper.shared
    
    func request(method: String, path: String, body: Encodable? = nil) -> URLRequest {
        let url = base.appendingPathComponent(path)
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "accept")
        
        if let requestBody = body {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .formatted(dateFormatters.dateFormatterFromApi)
            
            request.httpBody = try? encoder.encode(requestBody)
        }
        
        if let authorization = auth.authorizationHeader {
            request.addValue(
                authorization,
                forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    public func getSpends() async throws -> ([SpendsDTO], HTTPURLResponse) {
        let request = request(method: "GET", path: "spends")
        return try await performWithJsonResult(request)
    }
    
    public func addSpend(_ spend: Spends) async throws -> (SpendsDTO, HTTPURLResponse) {
        let request = request(method: "POST", path: "addSpend", body: spend)
        return try await performWithJsonResult(request)
    }
}

/// ObservableObject used for environmentObject
public class Network: ObservableObject {
    private lazy var urlSession: URLSession = .shared
    public var onUnauthorize: () -> Void = {}
    
    private let dateFormatters = DateFormatterHelper.shared
    
    func performWithStringResult(_ request: URLRequest) async throws -> (String, HTTPURLResponse) {
        
        let (data, response) = try await perform(request)
        
        let text = String(data: data, encoding: .utf8)!
        
        return (text, response)
    }
    
    func performWithJsonResult<T: Decodable>(_ request: URLRequest) async throws -> (T, HTTPURLResponse) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatters.dateFormatterToApi)
        
        let (data, response) = try await perform(request)
        
        let dto = try decoder.decode(T.self, from: data)
        
        return (dto, response)
    }
    
    func perform(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        print("Manually call \(request.httpMethod!) \(request.url!))")
        let (data, response) = try await urlSession.data(for: request)
        
        let urlResponse = response as! HTTPURLResponse
        if urlResponse.statusCode == 401 {
            onUnauthorize()
        }
        
        print("Did receive in the end \(urlResponse.url!)")
        return (data, urlResponse)
    }
}
