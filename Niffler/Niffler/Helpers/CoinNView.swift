import SwiftUI

struct CoinNView: View {
    var body: some View {
        VStack {
            Image("LogoNiffler")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 48, height: 48)
        }
    }
}
