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
    }
    
    func setupForUITests() {
        if ProcessInfo.processInfo.arguments.contains("RemoveAuthOnStart") {
            Auth.removeAuth()
            UIView.setAnimationsEnabled(false)
            UIApplication.shared.keyWindow?.layer.speed = 100
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
