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
}

extension NifflerApp {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .environmentObject(api)
        .environmentObject(userData)
    }
}
