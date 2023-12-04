import Foundation

protocol UserDefaultsWrapperProtocol {
    func set<T>(_ value: T, forKey key: String)
    func object<T>(forKey key: String) -> T?
    func removeObject(forKey key: String)
}

public class UserDefaultsWrapper: UserDefaultsWrapperProtocol {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }

    func set<T>(_ value: T, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }

    func object<T>(forKey key: String) -> T? {
        return userDefaults.object(forKey: key) as? T
    }

    func removeObject(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
}
