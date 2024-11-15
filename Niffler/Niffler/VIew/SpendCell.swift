import Api
import SwiftUI

struct SpendCell: View {
    @State private var isChecked: Bool = false
    var spend: Spends
    var body: some View {
        HStack {
            Toggle(isOn: $isChecked) {
            }
            .toggleStyle(CheckboxToggleStyle())
            .padding()

            VStack(alignment: .leading, spacing: 4) {
                Text("\(spend.description)")
                    .font(.system(size: 16))
                    .foregroundStyle(.primary)

                Text("\(spend.category.name)")
                    .font(.caption)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.primary.secondary)
            }

            VStack {
                HStack {
                    Spacer()
                    Text(spend.amountStringForUI)
                        .foregroundStyle(.primary)
                }

                HStack {
                    Spacer()
                    Text(spend.spendDateDescription)
                        .font(.caption)
                        .font(.system(size: 16))
                        .foregroundStyle(Color.primary.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.horizontal, 16)

            Image("ic_edit")
                .foregroundStyle(AppColors.gray_700)
        }
        .padding(.trailing, 16)
    }
}

let testSpend = Spends(
    id: nil,
    spendDate: DateFormatterHelper.shared.dateFormatterToApi.date(from: "2023-12-07T05:00:00.000+00:00")!,
    category: CategoryDTO(name: "test", archived: false),
    currency: "RUB",
    amount: 69.00,
    description: "Test Spend",
    username: "stage"
)

#Preview {
    SpendCell(spend: testSpend)
}
