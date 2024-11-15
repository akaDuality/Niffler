import Foundation

public struct UserDataModel: Codable, Sendable {
    public let id: String
    public let username: String
    public let firstname: String?
    public let surname: String?
    public let currency: String
    public let photo: String?
}
