import SwiftUI

struct PasswordField: View {
    let title: String
    let text: Binding<String>
    let isSecured: Bool
    let onPress: () -> Void

    var body: some View {
        ZStack(alignment: .trailing) {
            Group {
                if isSecured {
                    SecureField(title, text: text)
                } else {
                    TextField(title, text: text)
                }
            }

            Button {
                onPress()
            } label: {
                Image(isSecured ? "ic_show_hide" : "ic_show_open")
                    .accentColor(.gray)
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(8)
        .padding(.bottom, 20)
    }
}
