//
//  NifflerApp.swift
//  Niffler
//
//  Created by Mikhail Rubanov on 21.11.2023.
//

import Api
import SwiftData
import SwiftUI

@main
struct NifflerApp: App {
    let api = Api()
    let userData = UserData()
    let categoriesRepository: CategoriesRepository
    let spendsRepository: SpendsRepository
    
    init() {
        spendsRepository = SpendsRepository(api: api)
        categoriesRepository = CategoriesRepository(api: api, selectedCategory: Defaults.selectedCategory)
        
        setupForUITests()
        loadData()
    }
    
    func setupForUITests() {
        if CommandLine.arguments.contains("RemoveAuthOnStart") {
            Auth.removeAuth()
            UIView.setAnimationsEnabled(false)
            UIApplication.shared.keyWindow?.layer.speed = 100
        }
    }
    
    func loadData() {
        Task {
            guard api.auth.isAuthorized() else {
                print("Not fetch category because is unauthorized")
                return
            }
            
            try await categoriesRepository.loadCategories()
            // TODO: handle erros
        }
    }
}

extension NifflerApp {
    var body: some Scene {
        WindowGroup {
            MainView(isPresentLoginOnStart: !api.auth.isAuthorized())
        }
        .environmentObject(api)
        .environmentObject(userData)
        .environmentObject(categoriesRepository)
        .environmentObject(spendsRepository)
    }
}
