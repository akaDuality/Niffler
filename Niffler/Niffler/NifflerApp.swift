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
    @State var isRegistrationPresented: Bool = false

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

    var body: some Scene {
        WindowGroup {
            GeometryReader { geometry in
                VStack {
                    LogoutButton(geometry)
                        .frame(height: 69)

                    SpendsView(
                        network: network
                    )
                    .onAppear {
                        network.onUnauthorize = { isRegistrationPresented = true }
                    }
                    .sheet(isPresented: $isRegistrationPresented) {
                        LoginView(
                            isRegistrationPresented: self.$isRegistrationPresented,
                            auth: network.auth)
                    }
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }

    @ViewBuilder func LogoutButton(_ geometry: GeometryProxy) -> some View {
        Button(action: {
            isRegistrationPresented.toggle()
        }) {
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
