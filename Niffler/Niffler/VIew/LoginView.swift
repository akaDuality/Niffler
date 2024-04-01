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
    @EnvironmentObject var userData: UserData

    let onLogin: () -> Void
}

extension LoginView {
    var body: some View {
        VStack {
            VStack {
                HStack {
                    CoinN()
                    Text("Niffler")
                        .font(.custom("YoungSerif-Regular", size: 24))
                    // TODO: Add YoungSerif-Regular to Project
                        .bold()
                }
                
                VStack {
                    Text("Log in")
                        .font(.system(size: 48))
                    HStack {
                        Text("Don't have an account?")
                           
                        Text("Sign up")
                            .foregroundStyle(AppColors.blue_100)
                            .underline()
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
                
                
                HStack {
                    LoginButton()
//                    SignUpButton()
                }
            }
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
                .frame(width: 48, height: 48)
        }
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
                    Text("Login")
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(isLoginSuccessful ? Color.gray : AppColors.blue_100)
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
                        .tint(.white)
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

 #Preview {
     LoginView( onLogin: {})
 }
