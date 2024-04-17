//
//  NifflerApp.swift
//  Niffler
//
//  Created by Mikhail Rubanov on 21.11.2023.
//

import Api
import SwiftData
import SwiftUI

@main
struct NifflerApp: App {
    let api = Api()
    let userData = UserData()

    @State var isPresentLoginOnStart: Bool
    @State var isPresentLoginInModalScreen: Bool = false
    @State var showMenu: Bool = false

    init() {
        isPresentLoginOnStart = !api.auth.isAuthorized()
        setupForUITests()
    }

    func setupForUITests() {
        if CommandLine.arguments.contains("UITests") {
            UserDefaults.standard.removeObject(forKey: "UserAuthToken")
            isPresentLoginOnStart = false
        }
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    func fetchData() {
        Task {
            let (userDataModel, _) = try await api.currentUser()

            await MainActor.run {
                self.userData.setValues(from: userDataModel)
            }
        }
    }
}

extension NifflerApp {
    var body: some Scene {
        WindowGroup {
            if isPresentLoginOnStart {
                LoginView(
                    onLogin: { self.isPresentLoginOnStart = false }
                )
            } else {
                NavigationStack {
                    VStack {
                        HeaderView(
                            onPressLogout: { isPresentLoginInModalScreen = true },
                            onPressMenu: { showMenu.toggle() }
                        )
                        if showMenu {
                            MenuView()
                        } else {
                            Section {
                                SpendsView()
                                    .onAppear {
                                        // TODO: Check that is called on main queue
                                        api.auth.requestCredentialsFromUser = {
                                            isPresentLoginInModalScreen = true
                                        }
                                    }
                                    .sheet(isPresented: $isPresentLoginInModalScreen) {
                                        LoginView(onLogin: {
                                            self.isPresentLoginInModalScreen = false
                                        })
                                    }
                            }
                        }
                        Spacer()
                    }
                }
                .onAppear {
                    fetchData()
                }
            }
        }
        .environmentObject(api)
        .environmentObject(userData)
        .modelContainer(sharedModelContainer)
    }
}

struct HeaderView: View {
    @EnvironmentObject var api: Api
    @EnvironmentObject var userData: UserData
    @State private var loginState: LoginState = .login
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
            Image("ic_menu")
                .aspectRatio(contentMode: .fit)
                .onTapGesture {
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
