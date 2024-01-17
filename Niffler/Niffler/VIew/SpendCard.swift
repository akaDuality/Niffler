import Api
import SwiftUI

struct SpendCard: View {
    var spend: Spends
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading) {
                Text("\(spend.description)")
                    .foregroundStyle(.primary)

                Text("\(spend.category)")
                    .font(.caption)
                    .foregroundStyle(Color.primary.secondary)

                Text(spend.spendDate.map(DateFormatterHelper.shared.formatForUser) ?? "No data")
                    .font(.caption2)
                    .foregroundStyle(.gray)
            }
            
            Spacer()
            
            HStack(spacing: 5) {
                Text(currencyString(spend.amount, allowDigits: 2))
                    .fontWeight(.semibold)
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .background(.background, in: .rect(cornerRadius: 10))
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
