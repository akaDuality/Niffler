import Api
import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var api: Api
    @EnvironmentObject var userData: UserData
    @State private var loginState: LoginState = .login
    @State private var switchMenuIcon: Bool = false
    var onPressLogout: () -> Void
    var onPressMenu: () -> Void

    enum LoginState {
        case login
        case logouting
    }

    var body: some View {
        HStack(spacing: 10) {
            MenuButton()

            Spacer()

            LogoView(width: 32, height: 32)

            Spacer()

            ProfileButton()

            switch loginState {
            case .login:
                LogoutButton {
                    loginState = .logouting
                    Task {
                        try await api.auth.logout()
                        UserDefaults.standard.removeObject(forKey: "UserAuthToken")
                        await MainActor.run {
                            onPressLogout()
                            loginState = .login
                        }
                    }
                }
            case .logouting:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding(.horizontal, 12)
            }
        }
        .padding()
        .backgroundStyle(.gray)
    }

    @ViewBuilder
    func MenuButton() -> some View {
        VStack {
            Image(switchMenuIcon ? "ic_cross" : "ic_menu")
                .aspectRatio(contentMode: .fit)
                .onTapGesture {
                    switchMenuIcon.toggle()
                    onPressMenu()
                }
        }
    }

    @ViewBuilder
    func ProfileButton() -> some View {
        NavigationLink(destination: ProfileView()) {
            HStack {
                Image(systemName: "person.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
            }
            .padding(10)
            .foregroundColor(.blue)
            .cornerRadius(10)
        }
    }

    @ViewBuilder
    func LogoutButton(
        onPress: @escaping () -> Void
    ) -> some View {
        Button(action: onPress) {
            VStack(alignment: .trailing) {
                Text("Выйти")
                    .font(.callout)
            }
        }
    }
}

// #Preview {
//    HeaderView()
// }
