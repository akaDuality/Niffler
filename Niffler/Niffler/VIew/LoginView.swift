//
//  LoginView.swift
//  Niffler
//
//  Created by Станислав Карпенко on 21.11.2023.
//

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
    @State private var userAuthToken: String?
}

extension LoginView {
    var body: some View {
        NavigationView {
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

                Button(action: {
                    // logic
                    if !username.isEmpty && !password.isEmpty {
                        isLoginSuccessful = true
                    }
                    
                    
                }) {
                    Text("Login")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isLoginSuccessful ? Color.green : Color.blue)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 20)

                /// deprecated in 16.0
                NavigationLink(
                    destination:
                    VStack {
                        Text("Welcome \(username)!")
                        Token()
//                        SpendsView()
                    },
                    isActive: $isLoginSuccessful,
                    label: {
                        EmptyView()
                    }
                )
            }
            .padding()
            .navigationBarTitle("Login")
        }
    }

    @ViewBuilder
    func Token() -> some View {
        if let userAuthToken = userAuthToken {
            Text("Token: \(userAuthToken)")
        } else {
            Text("No token stored")
        }

        Button("Read Token") {
            // Retrieve token from UserDefaults
            self.userAuthToken = UserDefaults.standard.string(forKey: "UserAuthToken")
        }
    }

    @ViewBuilder
    func CoinN() -> some View {
        VStack {
            /// Main Ellipse
            Ellipse()
                .frame(width: 128, height: 128)
                .overlay(
                    /// Ellipse Delimeter
                    Ellipse()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(
                                    colors: [
                                        Color(UIColor(hex: 0xFFD992)),
                                        Color(UIColor(hex: 0xE1B15E)),
                                    ]
                                ),
                                startPoint: UnitPoint(x: 0, y: 0),
                                endPoint: UnitPoint(x: 1, y: 1)
                            )
                        )

                        .overlay(
                            Ellipse()
                                .fill(Color(UIColor(hex: 0xC39951)))
                                .frame(width: 105, height: 105)
                        )

                        .overlay(
                            Ellipse()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(
                                            stops: [
                                                .init(color: Color(UIColor(hex: 0xDEB35F)), location: 0.0),
                                                .init(color: Color(UIColor(hex: 0xCDA155)), location: 1.0),
                                            ]
                                        ),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                        )
                        .overlay(
                            Ellipse()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(
                                            stops: [
                                                .init(color: Color(UIColor(hex: 0xFFD992)), location: 0.276),
                                                .init(color: Color(UIColor(hex: 0xE1B15E)), location: 0.6823),
                                            ]
                                        ),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 83, height: 83)
                        )
                )
                .overlay(
                    Text("N")
                        .foregroundColor(Color(UIColor(hex: 0xC39951)))
                        .font(.largeTitle)
                )
                .padding()
        }
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
    LoginView()
}
