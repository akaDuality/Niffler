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
    
    @EnvironmentObject var api: Api

    @State private var presentAlert: Bool = false
    @State private var errorText: String?
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

            SignUpButton {
                do {
                    let responseCode = try await api.auth.register(
                        username: username,
                        password: password,
                        passwordSubmit: confirmPassword
                    )

                    await MainActor.run {
                        if responseCode == 201 {
                            presentAlert = true
                        } else {
                            errorText = "Не удалось создать пользователя"
                        }
                        isLoadingForSignUp = false
                    }
                } catch {
                    errorText = "Не удалось создать пользователя"
                }
            }
            .alert("Congratulations!", isPresented: $presentAlert) {
                Button {
                    self.isLoginViewPresent = true
                } label: {
                    Text("Log in")
                }
                
            } message: {
                Text(" You've registered!")
            }

            
            if let errorText {
                Text(errorText)
                    .font(.caption2)
                    .foregroundStyle(.red)
            }
        }
        .interactiveDismissDisabled()
    }
}

extension SignUpView {
    @ViewBuilder
    func SignUpButton(_ action: @escaping () async -> Void) -> some View {
        Button(action: {
            if !username.isEmpty && !password.isEmpty {
                isSignUpSuccessful = true
            }
            isLoadingForSignUp = true

            Task {
                await action()
            }
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
