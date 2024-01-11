import Foundation

@propertyWrapper
struct UserDefault<Value> {
    let key: String
    let defaultValue: Value
    var container: UserDefaults = .standard
    
    var wrappedValue: Value {
        get {
            return container.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            container.set(newValue, forKey: key)
        }
    }
}

/// https://github.com/qa-guru/niffler-st3/blob/00705308d259607c30447103cb7b9834afdf8209/niffler-e-2-e-tests/src/test/java/guru/qa/niffler/api/AuthService.java#L30
public class Auth: Network {
    let base = URL(string: "https://auth.niffler-stage.qa.guru")!
    let baseOauth = URL(string: "https://auth.niffler-stage.qa.guru/oauth2")!
    let challenge: String
    let verifier: PKCE.PKCECode
    
    var onCompleteRegistration: (() -> Void)?
    
    func completeRegistration() async throws {
        try await withUnsafeThrowingContinuation { completeRegistrationContinuation in
            self.onCompleteRegistration = {
                completeRegistrationContinuation.resume()
            }
        }
    }
    
    @UserDefault(key: "UserAuthToken", defaultValue: nil)
    private(set) var authorizationHeader: String?
                
    init(
        challenge: String? = nil
    ) {
        self.verifier = PKCE.generateCodeVerifier()
        self.challenge = challenge ?? (try! PKCE.codeChallenge(fromVerifier: verifier))
    }
    
    public func authorize(user: String, password: String) async throws {
        let authorizeRequest = authorizeRequest()
        let (_, authResponse) = try await perform(authorizeRequest)
        guard let xsrf = authResponse.allHeaderFields["x-xsrf-token"] as? String else {
            throw AuthorizationError.noXsrfToken
        }
        
        let loginRequest = loginRequest(login: user, password: password, xsrf: xsrf)
        let (_, loginResponse) = try await perform(loginRequest)
        
        guard let code = loginResponse.url?.query()?.components(separatedBy: "=").last else {
            throw AuthorizationError.noCode
        }
        
        if code.range(of: "error") != nil {
            throw AuthorizationError.noCode
        } 
        
        let request3 = tokenRequest(code: code)
        let (data3, _) = try await perform(request3)
        
        struct TokenDto: Decodable {
            let id_token: String
        }
        
        let decoder = JSONDecoder()
        let tokenDto = try decoder.decode(TokenDto.self, from: data3)
        self.authorizationHeader = "Bearer " + tokenDto.id_token
        onCompleteRegistration?()
    }
    
    public func isAuthorized() -> Bool {
        authorizationHeader != nil
    }
    
    private func request(
        baseURL: URL? = nil,
        method: String,
        path: String,
        query: [URLQueryItem] = [],
        addAcceptJsonHeader: Bool = true
    ) -> URLRequest {
        let url = (baseURL ?? baseOauth)
            .appendingPathComponent(path)
            .appending(queryItems: query)
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if addAcceptJsonHeader {
            request.addValue("application/json", forHTTPHeaderField: "accept")
        }
        
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
                    URLQueryItem(name: "redirect_uri", value: "https://niffler-stage.qa.guru/authorized".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)),
                    URLQueryItem(name: "code_challenge", value: challenge),
                    URLQueryItem(name: "code_challenge_method", value: "S256"),
                   ],
            addAcceptJsonHeader: false) // It brokes auth
        
        return request
    }
    
    /// - Parameters:
    ///   - xsrf: `x-xsrf-token` from authorize response
    private func loginRequest(
        login: String,
        password: String,
        xsrf: String
    ) -> URLRequest {
        var request = URLRequest(url: base.appending(path: "login"))
        
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded",
                         forHTTPHeaderField: "Content-Type")
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "username", value: login),
            URLQueryItem(name: "password", value: password),
            URLQueryItem(name: "_csrf", value: xsrf),
        ]
        
        request.httpBody = components.query?.data(using: .utf8)
        
        return request
    }
    
    private func tokenRequest(
        code: String
    ) -> URLRequest {
        var request = request(
            method: "POST",
            path: "token",
            query: [
                URLQueryItem(name: "client_id", value: "client"),
                
                URLQueryItem(name: "redirect_uri", value: "https://niffler-stage.qa.guru/authorized".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)),
                URLQueryItem(name: "code", value: code),
                URLQueryItem(name: "code_verifier", value: verifier),
                URLQueryItem(name: "grant_type", value: "authorization_code"),
            ])
        
        let token = "Basic " + "client:secret".toBase64()
        request.addValue(token,forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    public func register(username: String, password: String) async throws -> Int {
        let xsrf = try await getRegisterXSRF()
        
        let statusCode = try await postRegister(username: username,
                                                password: password,
                                                xsrf: xsrf)
        return statusCode
    }
    
    private func getRegisterXSRF() async throws -> String {
        var getRequest = URLRequest(url: base.appending(path: "register"))
        getRequest.httpMethod = "GET"
        
        let (_, getResponse) = try await perform(getRequest)
        
        let xsrf = (getResponse.allHeaderFields["x-xsrf-token"] as! String)
        return xsrf
    }
    
    private func postRegister(
        username: String,
        password: String,
        xsrf: String
    ) async throws -> Int {
        var postRequest = URLRequest(url: base.appending(path: "register"))
        
        postRequest.httpMethod = "POST"
        postRequest.setValue("application/x-www-form-urlencoded",
                             forHTTPHeaderField: "Content-Type")
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "username", value: username),
            URLQueryItem(name: "password", value: password),
            URLQueryItem(name: "passwordSubmit", value: password),
            URLQueryItem(name: "_csrf", value: xsrf),
        ]
        
        postRequest.httpBody = components.query?.data(using: .utf8)
        
        let (_, postResponse) = try await perform(postRequest)
        return postResponse.statusCode
    }
    
    enum AuthorizationError: Error {
        case noXsrfToken
        case noCode
        case invalidCode
    }
}

extension String {
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
