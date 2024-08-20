import Foundation

public struct RestPage<T: Codable>: Codable {
    public let content: [T]
}
