import SwiftUI

struct CheckboxToggleStyle: ToggleStyle {
  func makeBody(configuration: Self.Configuration) -> some View {
    HStack {
      Image(configuration.isOn ? "Checked=True" : "Checked=False")
        .resizable()
        .background(configuration.isOn ? AppColors.blue_100 : Color(.gray50))
        .foregroundColor(configuration.isOn ? AppColors.blue_100 : Color(.gray50))
        .frame(width: 24, height: 24)
        .onTapGesture { configuration.isOn.toggle() }
        .cornerRadius(4)
    }
  }
}
