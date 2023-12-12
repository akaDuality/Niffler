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

    let network = Api()
    
    @State var isPresentLoginOnStart: Bool
    @State var isPresentLoginInModalScreen: Bool = false
    
    init() {
        isPresentLoginOnStart = !network.auth.isAuthorized()
    }

    var body: some Scene {
        WindowGroup {
            if isPresentLoginOnStart {
                LoginView(auth: network.auth, onLogin: {
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
                        network.onUnauthorize = {
                            isPresentLoginInModalScreen = true
                        }
                    }
                    // TODO: Present in fullscreen or deprecate swipe down
                    .sheet(isPresented: $isPresentLoginInModalScreen) {
                        LoginView(auth: network.auth, onLogin: {
                            self.isPresentLoginInModalScreen = false
                            // TODO: Retry last request
                        })
                    }
                    
                }
            }
        }
        .modelContainer(sharedModelContainer)
        .environmentObject(network)
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
