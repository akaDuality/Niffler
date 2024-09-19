import Api
import SwiftUI

class UserData: ObservableObject {
    @Published var username = ""
    @Published var firstname: String? = ""
    @Published var surname: String? = ""
    @Published var currency = ""
    @Published var photo: String? = nil

    public init(username: String = "", firstname: String = "", surname: String = "", currency: String = "", photo: String? = nil) {
        self.username = username
        self.firstname = firstname
        self.surname = surname
        self.currency = currency
        self.photo = photo
    }

    public func setValues(from dto: UserDataModel) {
        username = dto.username
        firstname = dto.firstname
        surname = dto.surname
        currency = dto.currency
        photo = dto.photo
    }
}
