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

    @State var isPresentLoginOnStart: Bool
    @State var isPresentLoginInModalScreen: Bool = false

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
}

extension NifflerApp {
    var body: some Scene {
        WindowGroup {
            if isPresentLoginOnStart {
                LoginView(onLogin: {
                    self.isPresentLoginOnStart = false
                })
            } else {
                VStack {
                    Section {
                        SpendsView()
                            .onAppear {
                                // TODO: Check that is called on main queue
                                api.auth.requestCredentialsFromUser = {
                                    isPresentLoginInModalScreen = true
                                }
                            }
                            // TODO: Present in fullscreen or deprecate swipe down
                            .sheet(isPresented: $isPresentLoginInModalScreen) {
                                LoginView(onLogin: {
                                    self.isPresentLoginInModalScreen = false
                                })
                            }
                    } header: {
                        HeaderView()
                    }
                }
            }
        }
        .environmentObject(api)
        .modelContainer(sharedModelContainer)
    }

    @ViewBuilder
    func HeaderView() -> some View {
        HStack(spacing: 10) {
            Text("Welcome!")
                .font(.title.bold())

            Spacer()

            LogoutButton {
                UserDefaults.standard.removeObject(forKey: "UserAuthToken")
                isPresentLoginInModalScreen.toggle()
            }
        }
        .padding()
        .backgroundStyle(.gray)
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
