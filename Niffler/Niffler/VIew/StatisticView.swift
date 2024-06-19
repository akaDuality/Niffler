import Api
import Charts
import SwiftUI

struct StatisticView: View {
    @Binding var spends: [Spends]
    let totalAmount: Double = 30400

    var body: some View {
        VStack {
            HStack {
                Text("Statistic")
                    .font(Font.custom("YoungSerif-Regular", size: 24))
                    .padding()
                Spacer()
            }

            HStack {
                Chart(spends) { spend in
                    SectorMark(
                        angle: .value("Amount", spend.amount),
                        innerRadius: .ratio(0.8),
                        outerRadius: .inset(10)
                    )
                    .foregroundStyle(Color.random)
                }
                .overlay(
                    Text("\(totalAmount, specifier: "%.0f") ₽")
                        .bold()
                        .foregroundColor(.black)
                )
                .padding(.horizontal)

                // Legend
                VStack {
                    ForEach(spends) { spend in
                        CategoryLabel(spend)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    @ViewBuilder
    func CategoryLabel(_ spend: Spends) -> some View {
        HStack {
            Text(spend.category)
                .foregroundColor(.white)
            Spacer()
            Text("\(spend.amount, specifier: "%.0f") ₽")
                .foregroundColor(.white)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.random)
        .cornerRadius(25)
    }
}

extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0 ... 1),
            green: .random(in: 0 ... 1),
            blue: .random(in: 0 ... 1)
        )
    }
}

#Preview {
    StatisticView(spends:
            .constant(
        [
            Spends(
                spendDate: DateFormatterHelper.shared.dateFormatterToApi.date(from: "2023-12-07T05:00:00.000+00:00")!,
                category: "Рыбалка",
                currency: "RUB",
                amount: 180,
                description: "Test Spend",
                username: "stage"
            ),
            Spends(
                spendDate: DateFormatterHelper.shared.dateFormatterToApi.date(from: "2023-12-07T05:00:00.000+00:00")!,
                category: "Кальян",
                currency: "RUB",
                amount: 120,
                description: "Test Spend",
                username: "stage"
            ),
            Spends(
                spendDate: DateFormatterHelper.shared.dateFormatterToApi.date(from: "2023-12-07T05:00:00.000+00:00")!,
                category: "Не рыбалка",
                currency: "RUB",
                amount: 500,
                description: "Test Spend",
                username: "stage"
            ),
        ]
        )
    )
}
