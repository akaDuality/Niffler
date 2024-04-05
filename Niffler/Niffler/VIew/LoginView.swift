import Api
import SwiftUI

struct LoginView: View {
    @State private var username: String = Defaults.username
    @State private var password: String = Defaults.password
    @State private var isLoginSuccessful: Bool = false

    @State private var isLoadingForLogin: Bool = false
    @State private var isSignUpViewPresent: Bool = false

    @EnvironmentObject var api: Api
    @EnvironmentObject var userData: UserData

    let onLogin: () -> Void
}

extension LoginView {
    var body: some View {
        VStack {
            VStack {
                LogoView()

                VStack {
                    Text("Log in")
                        .font(.system(size: 48))
                    HStack {
                        Text("Don't have an account?")

                        Text("Sign up")
                            .foregroundStyle(AppColors.blue_100)
                            .underline()
                            .onTapGesture {
                                self.isSignUpViewPresent = true
                            }
                            .sheet(isPresented: $isSignUpViewPresent, content: {
                                SignUpView()
                            })
                    }
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
                    SecureField("Type your password", text: $password)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                        .padding(.bottom, 20)
                        .accessibilityIdentifier(LoginViewIDs.passwordTextField.rawValue)
                }
                .padding()

                LoginButton()
            }
        }
        .interactiveDismissDisabled()
    }

    @ViewBuilder
    func LoginButton() -> some View {
        Button(action: {
            isLoadingForLogin.toggle()

            Task {
                do {
                    try await api.auth.authorize(user: username, password: password)
                    let (userDataModel, response) = try await api.currentUser()
                    await MainActor.run {
                        userData.setValues(from: userDataModel)
                        onLogin()
                    }
                } catch let error {
                    // TODO: Present error on screen
                    print(error)
                }
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
