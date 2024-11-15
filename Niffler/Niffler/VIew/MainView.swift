import Api
import SwiftUI

struct MainView: View {
    
    @State var isPresentLoginOnStart: Bool
    @State var isPresentLoginInModalScreen = false
    @State var showMenu: Bool = false

    @EnvironmentObject var spendsRepository: SpendsRepository
    @EnvironmentObject var categoriesRepository: CategoriesRepository
    @EnvironmentObject var api: Api
    
    init(isPresentLoginOnStart: Bool) {
        self.isPresentLoginOnStart = isPresentLoginOnStart
    }

    let userData = UserData()

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
                    onLogin: {
                        // Just hide, login
                        self.isPresentLoginOnStart = false
                    }
                )
            } else {
                NavigationStack {
                    VStack {
                        if showMenu {
                            MenuView(
                                onPressLogout: {
                                    showMenu = false
                                    isPresentLoginInModalScreen = true
                                }
                            )
                            .padding(.bottom, 50) // Hide bottom during dismiss
                            .transition(.move(edge: .top))
                        }
                        
                        HeaderView(
                            spendsRepository: spendsRepository,
                            switchMenuIcon: false,
                            onPressMenu: { showMenu.toggle() }
                        )
                        Divider()
                        
                        Section {
                            SpendsView(spendsRepository: spendsRepository,
                                       categoriesRepository: categoriesRepository)
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
                        
                        Spacer()
                    }
                }.animation(.default, value: showMenu)
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
