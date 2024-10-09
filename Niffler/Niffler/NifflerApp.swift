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
        
        loadData()
    }
    
    func loadData() {
        Task {
            try await categoriesRepository.loadCategories()
            // TODO: handle erros
        }
    }
}

extension NifflerApp {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .environmentObject(api)
        .environmentObject(userData)
        .environmentObject(categoriesRepository)
        .environmentObject(spendsRepository)
        
    }
}
