import SwiftUI

struct LogoView: View {
    @State var width: CGFloat = 48
    @State var height: CGFloat = 48
    var body: some View {
        HStack {
            Image("LogoNiffler")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: width, height: height)
            
            Text("Niffler")
                .font(.custom("YoungSerif-Regular", size: 24))
                .bold()
        }
    }
}
