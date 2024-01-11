//
//  Network.swift
//  NifflerTests
//
//  Created by Mikhail Rubanov on 17.11.2023.
//

import Foundation

public class Api: Network {
    private let base = URL(string: "https://api.niffler-stage.qa.guru")!
    
    
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
        
        updateAuthorizationHeader(in: &request)
        
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
    
    
    // MARK: - Authorization
    public var authorize: () -> Void = {}
    public let auth = Auth()
    
    /// Should be called after login
    public private(set) var completeRegistration: (() -> Void)?
    
    func updateAuthorizationHeader(in request: inout URLRequest) {
        if let authorization = auth.authorizationHeader {
            request.allHTTPHeaderFields?["Authorization"] = authorization
        }
    }
    
    override func perform(
        _ request: URLRequest
    ) async throws -> (Data, HTTPURLResponse) {
        let (data, urlResponse) = try await super.perform(request)
        
        if urlResponse.statusCode == 401 {
            authorize() // Present login screen
            
            // Wait until user input credentials
            try await withUnsafeThrowingContinuation { completeRegistrationContinuation in
                self.completeRegistration = {
                    completeRegistrationContinuation.resume()
                }
            }
            
            var newRequest = URLRequest(url: request.url!)
            newRequest.httpMethod = request.httpMethod
            newRequest.httpBody = request.httpBody
            newRequest.allHTTPHeaderFields = request.allHTTPHeaderFields
            updateAuthorizationHeader(in: &newRequest)
            
            return try await super.perform(newRequest)
        }
        
        print("Did receive in the end \(urlResponse.url!)")
        return (data, urlResponse)
    }
}

/// ObservableObject used for environmentObject
public class Network: ObservableObject {
    private lazy var urlSession: URLSession = .shared
    
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
    
    func perform(
        _ request: URLRequest
    ) async throws -> (Data, HTTPURLResponse) {
        print("Manually call \(request.httpMethod!) \(request.url!))")
        let (data, response) = try await urlSession.data(for: request)
        
        let urlResponse = response as! HTTPURLResponse
        
        print("Did receive in the end \(urlResponse.url!)")
        return (data, urlResponse)
    }
}
