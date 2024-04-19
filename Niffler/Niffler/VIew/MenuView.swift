import SwiftUI

struct MenuView: View {
    @State private var showingProfile: Bool = false
}

extension MenuView {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Menu")
                .font(.custom("YoungSerif-regular", size: 24))

            HStack {
                Button {
                    showingProfile = true
                } label: {
                    Image("ic_user_gray")
                        .tint(Color.gray)
                    Text("Profile")
                }
                .sheet(isPresented: $showingProfile) {
                    ProfileView()
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 30)

            Divider()
                .padding(.vertical)

            HStack {
                Image("ic_friends_gray")
                Text("Friends")
            }
            .padding(.vertical)

            HStack {
                Image("ic_all_gray")
                Text("All people")
            }
            .padding(.vertical)

            Divider()
                .padding(.vertical)
                .frame(maxWidth: .infinity)

            HStack {
                Image("ic_signout_gray")
                Text("Sign out")
            }
            .padding(.vertical)

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    MenuView()
}
