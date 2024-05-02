import SwiftUI

// for debug, get data for environment
struct Defaults {
    static var username: String {
        ProcessInfo.processInfo.environment["username"] ?? ""
    }

    static var password: String {
        ProcessInfo.processInfo.environment["password"] ?? ""
    }

    static var amount: String {
        ProcessInfo.processInfo.environment["amount"] ?? ""
    }

    static var description: String {
        ProcessInfo.processInfo.environment["description"] ?? ""
    }

    static var selectedCategory: String {
        ProcessInfo.processInfo.environment["selectedCategory"] ?? ""
    }
}
