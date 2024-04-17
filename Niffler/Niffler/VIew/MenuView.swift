import SwiftUI

struct MenuView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Menu")
                .font(.custom("YoungSerif-regular", size: 24))

            HStack {
                Image(systemName: "person")
                    .foregroundStyle(.gray)
                    .imageScale(.large)
                Text("Profile")
                    .foregroundStyle(.gray)
                    .font(.headline)
            }
            .padding(.top, 30)

            Divider()
                .padding(.vertical)

            HStack {
                Image(systemName: "person.2")
                    .foregroundStyle(.gray)
                    .imageScale(.large)
                Text("Friends")
                    .foregroundStyle(.gray)
                    .font(.headline)
            }
            .padding(.vertical)

            HStack {
                Image(systemName: "globe")
                    .foregroundStyle(.gray)
                    .imageScale(.large)
                Text("All people")
                    .foregroundStyle(.gray)
                    .font(.headline)
            }
            .padding(.vertical)

            Divider()
                .padding(.vertical)
                .frame(maxWidth: .infinity)

            HStack {
                Image(systemName: "person.crop.circle.badge.minus")
                    .foregroundStyle(.gray)
                    .imageScale(.large)
                Text("Sign out")
                    .foregroundStyle(.gray)
                    .font(.headline)
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
