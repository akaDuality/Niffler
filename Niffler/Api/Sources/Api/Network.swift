//
//  Network.swift
//  NifflerTests
//
//  Created by Mikhail Rubanov on 17.11.2023.
//

import Foundation

public class Api: Network {
    private let base = ApiConfig().urls.apiURL
    
    
    public override init() { super.init() }
    
    private let dateFormatters = DateFormatterHelper.shared
    
    func request(method: String, path: String,  queryParams: [String:String] = [:], body: Encodable? = nil) -> URLRequest {
        let baseUrl = base.appendingPathComponent(path)
        var urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        guard let url = urlComponents.url else {
            fatalError("Invalid URL")
        }

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
    
    public func currentUser() async throws -> (UserDataModel, HTTPURLResponse) {
        let request = request(method: "GET", path: "api/users/current")
        return try await performWithJsonResult(request)
    }
    
    public func getSpends() async throws -> (SpendsDTO, HTTPURLResponse) {
        let queryParams = [
            "sort": "spendDate,desc"
        ]
        let request = request(method: "GET", path: "/api/v2/spends/all", queryParams: queryParams)
        return try await performWithJsonResult(request)
    }
    
    public func addSpend(_ spend: Spends) async throws -> (SpendsContentDTO, HTTPURLResponse) {
        let request = request(method: "POST", path: "/api/spends/add", body: spend)
        return try await performWithJsonResult(request)
    }
    
    public func getStat() async throws -> (StatDTO, HTTPURLResponse) {
        let queryParams = [
            "filterCurrency": "",
            "statCurrency": "",
            "filterPeriod": ""
        ]
        let request = request(method: "GET", path: "/api/v2/stat/total", queryParams: queryParams)
        return try await performWithJsonResult(request)
    }
    
    // MARK: - Authorization
    
    public let auth = Auth()
    
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
            do {
                return try await authorizeAndRetry(request)
            } catch {
                print("Auth failed, return original data")
                return (data, urlResponse)
            }
        }
        
        print("Did receive in the end \(urlResponse.url!)")
        return (data, urlResponse)
    }
    
    private func authorizeAndRetry(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let url = request.url!
        print("Got 401 for \(url)")
        
        try await waitForAuthorizationResult()
        
        print("Retry request \(url)")
        var newRequest = request.copy()
        updateAuthorizationHeader(in: &newRequest)
        return try await super.perform(newRequest)
        
    }
    
    private func waitForAuthorizationResult() async throws {
        if let loginTask = loginTask {
            print("Wait for login, add to queue")
            try await loginTask.value
        } else {
            loginTask = Task {
                print("Show auth UI")
                try await auth.authorize()
            }
            
            try await loginTask!.value
        }
    }
    
    private var loginTask: Task<Void, Error>?
}

extension URLRequest {
    func copy() -> URLRequest {
        var newRequest = URLRequest(url: url!)
        newRequest.httpMethod = httpMethod
        newRequest.httpBody = httpBody
        newRequest.allHTTPHeaderFields = allHTTPHeaderFields
        return newRequest
    }
    
    func withAuthorizationHeader(_ header: String?) -> URLRequest {
        var newRequest = copy()
        if let authorization = header {
            newRequest.allHTTPHeaderFields?["Authorization"] = authorization
        }
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
