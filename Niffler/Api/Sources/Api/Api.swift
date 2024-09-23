import Foundation

public class Api: Network {
    private let base = ApiConfig().urls.apiURL
    
    public override init() { super.init() }
    
    private let dateFormatters = DateFormatterHelper.shared
    
    func request(method: String, path: String, queryParams: [String:String] = [:], body: Encodable? = nil) -> URLRequest {
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
    
    // MARK: - Authorization
    
    public let auth = Auth()
    
    func updateAuthorizationHeader(in request: inout URLRequest) {
        if let authorization = auth.authorizationHeader {
            // Rewrite header, instead of appending to allow retry with different authorization
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
