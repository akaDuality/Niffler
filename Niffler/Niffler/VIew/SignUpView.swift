import Api
import SwiftUI

struct SignUpView: View {
    @State private var username: String = Defaults.username
    @State private var password: String = Defaults.password
    @State private var confirmPassword: String = Defaults.password
    @State private var isLoadingForSignUp: Bool = false
    @State private var isSignUpSuccessful: Bool = false
    @State private var isLoginViewPresent: Bool = false
    @State private var isSecuredPassword: Bool = true
    @State private var isSecuredConfirm: Bool = true
}

extension SignUpView {
    var body: some View {
        VStack {
            LogoView()

            VStack {
                Text("Sign Up")
                    .font(.custom("YoungSerif-Regular", size: 48))

                HStack {
                    Text("Already have an account?")

                    Text("Log in")
                        .foregroundStyle(AppColors.blue_100)
                        .underline()
                        .onTapGesture {
                            self.isLoginViewPresent = true
                        }
                        .sheet(isPresented: $isLoginViewPresent, content: {
                            LoginView(onLogin: {})
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
                    .accessibilityIdentifier(SignUpViewIDs.userNameTextField.rawValue)

                Text("Password")
                PasswordField(
                    title: "Type your password",
                    text: $password,
                    isSecured: isSecuredPassword,
                    onPress: { self.isSecuredPassword.toggle() }
                )
                .accessibilityIdentifier(SignUpViewIDs.passwordTextField.rawValue)

                Text("Confirm password")
                PasswordField(
                    title: "Type your password",
                    text: $confirmPassword,
                    isSecured: isSecuredConfirm,
                    onPress: { self.isSecuredConfirm.toggle() }
                )
                .accessibilityIdentifier(SignUpViewIDs.confirmPasswordTextField.rawValue)
            }
            .padding()

            SignUpButton()
        }
        .interactiveDismissDisabled()
    }
}

extension SignUpView {
    @ViewBuilder
    func SignUpButton() -> some View {
        Button(action: {
            if !username.isEmpty && !password.isEmpty {
                isSignUpSuccessful = true
            }
            isLoadingForSignUp.toggle()

            // #TODO: add logic for sigh up

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
            .background(isSignUpSuccessful ? AppColors.green : AppColors.blue_100)
            .cornerRadius(8)
        }
        .disabled(isSignUpSuccessful)
        .padding(.horizontal, 20)
    }
}
