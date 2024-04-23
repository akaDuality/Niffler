import Api
import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var api: Api
    @EnvironmentObject var userData: UserData
    @State var spends: [Spends] = []
    @State var isPresentAddSpendView = false
    @State var switchMenuIcon: Bool
    var onPressMenu: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            MenuButton()

            Spacer()

            LogoView(width: 36, height: 36)

            Spacer()

            AddSpendButton()
        }
        .padding(.horizontal)
    }
}

extension HeaderView {
    @ViewBuilder
    func MenuButton() -> some View {
        HStack {
            Rectangle()
                .frame(width: 48, height: 48)
                .foregroundStyle(AppColors.gray_100)
                .cornerRadius(10)
                .overlay {
                    Image(switchMenuIcon ? "ic_cross" : "ic_menu")
                        .padding()
                }
                .onTapGesture {
                    switchMenuIcon.toggle()
                    onPressMenu()
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(AppColors.gray_300, lineWidth: 1)
                )
        }
    }

    @ViewBuilder
    func AddSpendButton() -> some View {
        HStack {
            Button(action: {
                isPresentAddSpendView = true
            }) {
                Rectangle()
                    .frame(width: 48, height: 48)
                    .foregroundStyle(AppColors.blue_100)
                    .cornerRadius(10)
                    .overlay {
                        Image("ic_plus")
                            .padding()
                    }
            }
        }
        .sheet(isPresented: $isPresentAddSpendView) {
            DetailSpendView(
                spends: $spends,
                onAddSpend: {
                    self.isPresentAddSpendView = false
                }
            )
        }
        .accessibilityIdentifier(SpendsViewIDs.addSpendButton.rawValue)
    }
}

// #Preview {
//    HeaderView()
// }
