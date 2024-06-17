import Api
import SwiftUI

struct LoginView: View {
    @State private var username: String = Defaults.username
    @State private var password: String = Defaults.password

    @State private var isLoginSuccessful: Bool = false
    @State private var isLoadingForLogin: Bool = false
    @State private var isSignUpViewPresent: Bool = false
    @State private var isSecured: Bool = true

    @EnvironmentObject var api: Api
    @EnvironmentObject var userData: UserData

    let onLogin: () -> Void

    @State private var errorText: String?
}

extension LoginView {
    var body: some View {
        NavigationView {
            VStack {
                LogoView()

                VStack {
                    Text("Log in")
                        .font(Font.custom("YoungSerif-Regular", size: 48))
                }

                VStack(alignment: .leading) {
                    Text("Username")
                    TextField("Type your username", text: $username)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                        .padding(.bottom, 20)
                        .accessibilityIdentifier(LoginViewIDs.userNameTextField.rawValue)

                    Text("Password")
                    PasswordField(
                        title: "Type your password",
                        text: $password,
                        isSecured: isSecured,
                        onPress: { self.isSecured.toggle() }
                    )
                    .accessibilityIdentifier(LoginViewIDs.passwordTextField.rawValue)
                }
                .padding()

                LoginButton {
                    do {
                        try await api.auth.authorize(user: username, password: password)
                        let (userDataModel, response) = try await api.currentUser()
                        await MainActor.run {
                            userData.setValues(from: userDataModel)
                            onLogin()
                        }
                    } catch let error {
                        errorText = "Нет такого пользователя. Попробуйте другие данные"
                    }
                }

                if let errorText {
                    Text(errorText)
                        .font(.caption2)
                        .foregroundStyle(.red)
                }

                Divider()
                    .padding(.top, 16)

                NavigationLink(destination: SignUpView()) {
                    CreateNewAccountButton()
                }
            }
        }
        .interactiveDismissDisabled()
    }

    @ViewBuilder
    func LoginButton(_ action: @escaping () async -> Void) -> some View {
        Button(action: {
            isLoadingForLogin.toggle()

            Task {
                await action()
            }
        }) {
            HStack {
                if isLoadingForLogin {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Log in")
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(isLoginSuccessful ? AppColors.green : AppColors.blue_100)
            .cornerRadius(8)
        }
        .disabled(isLoadingForLogin)
        .padding(.horizontal, 20)
        .accessibilityIdentifier(LoginViewIDs.loginButton.rawValue)
    }

    @ViewBuilder
    func CreateNewAccountButton() -> some View {
        Text("Create new account")
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(AppColors.green)
            .cornerRadius(8)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
    }
}

extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

#Preview {
    LoginView(onLogin: {})
}
