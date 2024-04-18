import SwiftUI
import Api

struct MainView: View {
    @State var isPresentLoginInModalScreen = false
    @State var showMenu: Bool = false
    @EnvironmentObject var api: Api
    
    var body: some View {
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
}

#Preview {
    MainView()
}
