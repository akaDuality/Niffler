import Api
import SwiftUI

struct LoginView: View {
    @State private var username: String = Defaults.username
    @State private var password: String = Defaults.password
    @State private var isLoginSuccessful: Bool = false
    @State private var isSignUpSuccessful: Bool = false
    @State private var isLoadingForLogin: Bool = false
    @State private var isLoadingForSignUp: Bool = false

    @EnvironmentObject var api: Api
    let onLogin: () -> Void
}

extension LoginView {
    var body: some View {
        VStack {
            VStack {
                CoinN()

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
                HStack {
                    LoginButton()
                    SignUpButton()
                }
            }
            .padding()
            .navigationBarTitle("Login")
        }
        .interactiveDismissDisabled()
    }

    @ViewBuilder
    func CoinN() -> some View {
        VStack {
            Image("LogoNiffler")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
        }
    }

    @ViewBuilder
    func LoginButton() -> some View {
        Button(action: {
            isLoadingForLogin.toggle()

            Task {
                do {
                    try await api.auth.authorize(user: username, password: password)
                    await MainActor.run {
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
                } else {
                    Text("Login")
                }
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(isLoginSuccessful ? Color.gray : Color.blue)
            .cornerRadius(8)
        }
        .disabled(isLoadingForLogin)
        .padding(.horizontal, 20)
        .accessibilityIdentifier(LoginViewIDs.loginButton.rawValue)
    }

    @ViewBuilder
    func SignUpButton() -> some View {
        Button(action: {
            if !username.isEmpty && !password.isEmpty {
                isSignUpSuccessful = true
            }
            isLoadingForSignUp.toggle()

            // #TODO add logic for sigh up

        }) {
            HStack {
                if isLoadingForSignUp {
                    ProgressView()
                } else {
                    Text("Sign Up")
                }
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(isSignUpSuccessful ? Color.gray : Color.purple)
            .cornerRadius(8)
        }
        .disabled(isSignUpSuccessful)
        .padding(.horizontal, 20)
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

// #Preview {
//    LoginView()
// }
