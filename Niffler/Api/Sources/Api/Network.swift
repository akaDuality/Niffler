//
//  Network.swift
//  NifflerTests
//
//  Created by Mikhail Rubanov on 17.11.2023.
//

import Foundation



extension URLRequest {
    func copy() -> URLRequest {
        var newRequest = URLRequest(url: url!)
        newRequest.httpMethod = httpMethod
        newRequest.httpBody = httpBody
        newRequest.allHTTPHeaderFields = allHTTPHeaderFields
        return newRequest
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
        
        do {
            let dto = try decoder.decode(T.self, from: data)
            return (dto, response)
        } catch {
            let text = String(data: data, encoding: .utf8)!
            print("Can't decode\n\(text)")
            throw error
        }
    }
    
//    "{\"type\":\"about:blank\",\"title\":\"Bad Request\",\"status\":400,\"detail\":\"Spending currency should be same with user currency\",\"instance\":\"/api/spends/add\"}"
    
    func perform(
        _ request: URLRequest
    ) async throws -> (Data, HTTPURLResponse) {
        print("Will call \(request.httpMethod!) \(request.url!))")
        
        let (data, response) = try await urlSession.data(for: request)
        
        let urlResponse = response as! HTTPURLResponse
        let statusCode = urlResponse.statusCode
        print("Did call \(urlResponse.url!), \(statusCode)")
        return (data, urlResponse)
    }
}
