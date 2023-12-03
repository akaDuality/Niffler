//
//  LoginView.swift
//  Niffler
//
//  Created by Станислав Карпенко on 21.11.2023.
//

import Api
import SwiftUI

struct Defaults {
    static var username: String {
        ProcessInfo.processInfo.environment["username"] ?? ""
    }

    static var password: String {
        ProcessInfo.processInfo.environment["password"] ?? ""
    }
}

struct LoginView: View {
    @State private var username: String = Defaults.username
    @State private var password: String = Defaults.password
    @State private var isLoginSuccessful: Bool = false
    @State private var isSignUpSuccessful: Bool = false
    @State private var userAuthToken: String?
    @State private var isLoadingForLogin: Bool = false
    @State private var isLoadingForSignUp: Bool = false
    @Binding var isRegistrationPresented: Bool
    let auth: Auth
}

extension LoginView {
    var body: some View {
        VStack {
            VStack {
                CoinN()

                TextField("Username", text: $username)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                    .padding(.bottom, 20)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                    .padding(.bottom, 20)

                HStack {
                    LoginButton()
                    SignUpButton()
                }
            }
            .padding()
            .navigationBarTitle("Login")
        }
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
            if !username.isEmpty && !password.isEmpty {
                isLoginSuccessful = true
            }
            isLoadingForLogin.toggle()

            Task {
                try await auth.authorize(user: username, password: password)
                await MainActor.run {
                    isRegistrationPresented = false
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
        .padding(.horizontal, 20)
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
