import Api
import Charts
import SwiftUI

struct StatisticView: View {
    @Binding var spends: [Spends]
    var totalAmount: Double { spends.reduce(0.0) { result, spend in
        result + spend.amount
    }}

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

                Legend(spends: spends)
            }
        }
    }

    @ViewBuilder
    func Legend(spends: [Spends]) -> some View {
        VStack {
            ForEach(sortedCategory(spends: spends), id: \.0) { key, value in
                CategoryLabel(key, value)
            }
        }
    }

    @ViewBuilder
    func CategoryLabel(_ category: String, _ amount: Double) -> some View {
        HStack {
            Text("\(category) \(amount, specifier: "%.0f") ₽")
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
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

extension StatisticView {
    func sortedCategory(spends: [Spends]) -> [(String, Double)] {
        var categoryTotals: [String: Double] = [:]

        for spend in spends {
            categoryTotals[spend.category, default: 0.0] += spend.amount
        }

        let sortedCategoryTotals = categoryTotals.sorted(by: { $0.key < $1.key })

        return sortedCategoryTotals
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
