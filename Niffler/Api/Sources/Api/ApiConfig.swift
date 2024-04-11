import Foundation

class ApiConfig {
    var baseAuthURL: URL
    var baseApiURL: URL
    var baseURL: URL
    
    init() {
        baseAuthURL = ApiUrls.stage.authURL
        baseApiURL = ApiUrls.stage.apiURL
        baseURL = ApiUrls.stage.baseURL
        switchConfig(to: .stage)
    }
    
    func switchConfig(to type: TypeEnvironment) {
        switch type {
        case .stage:
            baseAuthURL = ApiUrls.stage.authURL
            baseApiURL = ApiUrls.stage.apiURL
            baseURL = ApiUrls.stage.baseURL
        case .local:
            baseAuthURL = ApiUrls.local.authURL
            baseApiURL = ApiUrls.local.apiURL
            baseURL = ApiUrls.local.baseURL
        }
    }
    
    enum TypeEnvironment {
        case stage
        case local
    }
}

struct ApiUrls {
    var authURL: URL
    var apiURL: URL
    var baseURL: URL
    
    init(authURL: String, apiURL: String, baseURL: String) {
        self.authURL = URL(string: authURL)!
        self.apiURL = URL(string: apiURL)!
        self.baseURL = URL(string: baseURL)!
    }
    
    static var stage = ApiUrls(
        authURL: "https://auth.niffler-stage.qa.guru",
        apiURL: "https://api.niffler-stage.qa.guru",
        baseURL: "https://niffler-stage.qa.guru"
    )
    
    static var local = ApiUrls(
        authURL: "http://auth.niffler.dc",
        apiURL: "http://gateway.niffler.dc",
        baseURL: "http://frontend.niffler.dc"
    )
}
