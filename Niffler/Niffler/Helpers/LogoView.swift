import SwiftUI

struct LogoView: View {
    var body: some View {
        HStack {
            Image("LogoNiffler")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 48, height: 48)
            
            Text("Niffler")
                .font(.custom("YoungSerif-Regular", size: 24))
                .bold()
        }
    }
}
