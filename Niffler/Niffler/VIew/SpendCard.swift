import Api
import SwiftUI

struct SpendCard: View {
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

                Text("\(spend.category)")
                    .font(.caption)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.primary.secondary)
            }

            VStack {
                HStack {
                    Spacer()
                    Text(currencyString(spend.amount, allowDigits: 0))
                        .foregroundStyle(.primary)
                }

                HStack {
                    Spacer()
                    Text(spend.spendDate.map(DateFormatterHelper.shared.formatForUser) ?? "No data")
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
    spendDate: DateFormatterHelper.shared.dateFormatterToApi.date(from: "2023-12-07T05:00:00.000+00:00")!,
    category: "Рыбалка",
    currency: "RUB",
    amount: 69.00,
    description: "Test Spend",
    username: "stage"
)

#Preview {
    SpendCard(spend: testSpend)
}
