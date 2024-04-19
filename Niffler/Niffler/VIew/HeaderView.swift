import Api
import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var api: Api
    @EnvironmentObject var userData: UserData
    @State var switchMenuIcon: Bool
    var onPressMenu: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            MenuButton()

            Spacer()

            LogoView(width: 32, height: 32)

            Spacer()
        }
        .padding()
        .backgroundStyle(.gray)
    }

    @ViewBuilder
    func MenuButton() -> some View {
        VStack {
            Image(switchMenuIcon ? "ic_cross" : "ic_menu")
                .aspectRatio(contentMode: .fit)
                .onTapGesture {
                    switchMenuIcon.toggle()
                    onPressMenu()
                }
        }
    }
}

// #Preview {
//    HeaderView()
// }
