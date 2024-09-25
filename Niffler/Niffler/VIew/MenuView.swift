import Api
import SwiftUI

struct MenuView: View {
    @EnvironmentObject var api: Api
    @State private var showingProfile: Bool = false
    @State private var loginState: LoginState = .login

    var onPressLogout: () -> Void

    enum LoginState {
        case login
        case logouting
    }
}

extension MenuView {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Menu")
                .font(.custom("YoungSerif-regular", size: 24))

            Button {
                showingProfile = true
            } label: {
                HStack {
                    Image("ic_user_gray")
                        .tint(Color.gray)
                    Text("Profile")
                }
                .sheet(isPresented: $showingProfile) {
                    NavigationView() {
                        ProfileView()
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarItems(trailing: Button("Close") {
                                showingProfile = false
                                // TODO: Ask to save?
                            })
                    }
                }
                .buttonStyle(.plain)
            }

            Divider()
                .padding(.vertical)

            HStack {
                Image("ic_friends_gray")
                Text("Friends")
            }
            .padding(.vertical)

            HStack {
                Image("ic_all_gray")
                Text("All people")
            }
            .padding(.vertical)

            Divider()
                .padding(.vertical)
                .frame(maxWidth: .infinity)

            HStack {
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
            .padding(.vertical)

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    func LogoutButton(
        onPress: @escaping () -> Void
    ) -> some View {
        Button(action: onPress) {
            HStack {
                Image("ic_signout_gray")
                Text("Sign out")
            }
        }
    }
}

#Preview {
    MenuView(onPressLogout: {})
}
