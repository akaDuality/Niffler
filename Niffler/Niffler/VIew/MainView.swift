import Api
import SwiftUI

struct MainView: View {
    @State var isPresentLoginOnStart: Bool = false
    @State var isPresentLoginInModalScreen = false
    @State var showMenu: Bool = false
    @State var spends: [Spends] = []
    @EnvironmentObject var api: Api {
        didSet {
            isPresentLoginOnStart = !api.auth.isAuthorized()
            
        }
    }
    
    init() {
        setupForUITests()
    }

    let userData = UserData()


    func setupForUITests() {
        if CommandLine.arguments.contains("RemoveAuthOnStart") {
            Auth.removeAuth()
        }
    }

    func fetchData() {
        Task {
            let (userDataModel, _) = try await api.currentUser()

            await MainActor.run {
                self.userData.setValues(from: userDataModel)
            }
        }
    }
}

extension MainView {
    var body: some View {
        VStack {
            if isPresentLoginOnStart {
                LoginView(
                    onLogin: { self.isPresentLoginOnStart = false }
                )
            } else {
                NavigationStack {
                    VStack {
                        HeaderView(
                            spends: $spends,
                            switchMenuIcon: false,
                            onPressMenu: { showMenu.toggle() }
                        )
                        Divider()
                        if showMenu {
                            MenuView(
                                onPressLogout: {
                                    showMenu = false
                                    isPresentLoginInModalScreen = true
                                }
                            )
                        } else {
                            Section {
                                SpendsView(spends: $spends)
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
    }
}

//#Preview {
//    MainView()
//}
