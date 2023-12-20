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
                GeometryReader { geometry in
                    VStack {
                        LogoutButton(geometry) {
                            UserDefaults.standard.removeObject(forKey: "UserAuthToken")
                            isPresentLoginInModalScreen.toggle()
                        }
                        .frame(height: 69)
                        
                        SpendsView()
                    }
                    .onAppear {
                        // TODO: Check that is called on main queue
                        api.onUnauthorize = {
                            isPresentLoginInModalScreen = true
                        }
                    }
                    // TODO: Present in fullscreen or deprecate swipe down
                    .sheet(isPresented: $isPresentLoginInModalScreen) {
                        LoginView(onLogin: {
                            self.isPresentLoginInModalScreen = false
                            // TODO: Retry last request
                        })
                    }
                    
                }
            }
        }
        .modelContainer(sharedModelContainer)
        .environmentObject(api)
    }
    

    

    @ViewBuilder func LogoutButton(
        _ geometry: GeometryProxy,
        onPress: @escaping () -> Void
    ) -> some View {
        Button(action: onPress) {
            Spacer()
            Text("Выйти")
                .padding()
                .frame(width: geometry.size.width * 0.8)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            Spacer()
        }
    }
}
