import Api
import SwiftUI

struct StartPage: View {
    let onEnd: () -> Void

    var body: some View {
        NavigationView {
            VStack {
                LogoView()
                    .padding(.vertical, 36)

                NavigationLink(destination:
                    SignUpView()
                ) {
                    Text("Sign Up")
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(AppColors.blue_100)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 16)

                NavigationLink(destination:
                    LoginView(onLogin: {
                        onEnd()
                    })
                ) {
                    Text("Log in")
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(AppColors.gray_1000)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 32)
            }
            .padding()
        }
    }
}

// #Preview {
//    StartPage(onLogin: {})
// }
