import Foundation

extension Api {
    // MARK: User
    public func currentUser() async throws -> (UserDataModel, HTTPURLResponse) {
        let request = request(method: "GET", path: "api/users/current")
        return try await performWithJsonResult(request)
    }
    
    // MARK: Spends
    public func getSpends() async throws -> (SpendsDTO, HTTPURLResponse) {
        let queryParams = [
            "sort": "spendDate,desc"
        ]
        let request = request(method: "GET", path: "/api/v2/spends/all", queryParams: queryParams)
        return try await performWithJsonResult(request)
    }
    
    public func addSpend(_ spend: Spends) async throws -> (Spends, HTTPURLResponse) {
        let request = request(method: "POST", path: "/api/spends/add", body: spend)
        return try await performWithJsonResult(request)
    }
    
    public func editSpend(_ spend: Spends) async throws -> (Spends, HTTPURLResponse) {
        precondition(spend.id != nil)
        let request = request(method: "PATCH", path: "/api/spends/edit", body: spend)
        return try await performWithJsonResult(request)
    }
    
    // MARK: Categories
    public func categories() async throws -> ([CategoryDTO], HTTPURLResponse) {
        let request = request(method: "GET", path: "/api/categories/all")
        return try await performWithJsonResult(request)
    }
    
    public func addCategory(_ category: CategoryDTO) async throws -> (CategoryDTO, HTTPURLResponse) {
        let request = request(method: "POST", path: "/api/categories/add", body: category)
        return try await performWithJsonResult(request)
    }
    
    public func updateCategory(_ category: CategoryDTO) async throws -> (CategoryDTO, HTTPURLResponse) {
        let request = request(method: "PATCH", path: "/api/categories/update", body: category)
        return try await performWithJsonResult(request)
    }
    
    // MARK: Stats
    public func getStat() async throws -> (StatDTO, HTTPURLResponse) {
        let queryParams = [
            "filterCurrency": "",
            "statCurrency": "",
            "filterPeriod": ""
        ]
        let request = request(method: "GET", path: "/api/v2/stat/total", queryParams: queryParams)
        return try await performWithJsonResult(request)
    }
}
