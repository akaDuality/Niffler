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

//            Spacer()

            VStack(spacing: 4) {
                HStack(spacing: 5) {
                    Text(currencyString(spend.amount, allowDigits: 0))
                        .foregroundStyle(.primary)
                }
                Text(spend.spendDate.map(DateFormatterHelper.shared.formatForUser) ?? "No data")
                    .font(.caption)
                    .foregroundStyle(Color.primary.secondary)
            }.frame(maxWidth: .infinity, alignment: .trailing)

            Image("ic_edit")
                .foregroundStyle(AppColors.gray_700)
        }
        .padding(.trailing, 8)
        .padding(.top, 16)
//        .background(.background, in: .rect(cornerRadius: 10))
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
