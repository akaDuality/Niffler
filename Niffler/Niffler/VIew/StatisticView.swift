import Api
import Charts
import SwiftUI

struct StatisticView: View {
    @Binding var spends: [Spends]
    @State private var groupedSpendsWithColor: GroupedSpendsWithColor

    init(spends: Binding<[Spends]>) {
        _spends = spends
        _groupedSpendsWithColor = State(initialValue: GroupedSpendsWithColor(spends: spends.wrappedValue))
    }

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
                CustomChart(spends: spends)
                Legend(spends: spends)
            }
        }
    }

    @ViewBuilder
    func CustomChart(spends: [Spends]) -> some View {
        Chart(groupedSpendsWithColor.array) { spend in
            SectorMark(
                angle: .value("Amount", spend.amount),
                innerRadius: .ratio(0.8),
                outerRadius: .inset(10)
            )
            .foregroundStyle(spend.color)
        }.overlay(
            Text("\(totalAmount, specifier: "%.0f") ₽")
                .bold()
                .foregroundColor(.black)
        )
    }

    @ViewBuilder
    func Legend(spends: [Spends]) -> some View {
        VStack {
            ForEach(groupedSpendsWithColor.array) { spend in
                CategoryLabel(spend.category,
                              spend.amount,
                              spend.color)
            }
        }
    }

    @ViewBuilder
    func CategoryLabel(_ category: String, _ amount: Double, _ color: Color) -> some View {
        HStack {
            Text("\(category) \(amount, specifier: "%.0f") ₽")
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(color)
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

struct GroupedSpendsWithColor {
    var array: [GroupedSpends]
    struct GroupedSpends: Identifiable {
        var id: UUID

        var category: String
        var amount: Double
        var color: Color
    }

    init(spends: [Spends]) {
        let staticSpends = sortedCategory(spends: spends)

        array = staticSpends.map { category, amount, color in
            GroupedSpends(id: UUID(), category: category, amount: amount, color: color)
        }
    }
}

private func sortedCategory(spends: [Spends]) -> [(String, Double, Color)] {
    var categoryTotals: [String: Double] = [:]

    for spend in spends {
        categoryTotals[spend.category, default: 0.0] += spend.amount
    }

    let sortedCategoryTotals = categoryTotals.sorted(by: { $0.key < $1.key })
    var categorizedData: [(String, Double, Color)] = []
    for (category, total) in sortedCategoryTotals {
        let randomColor = Color.random
        categorizedData.append((category, total, randomColor))
    }

    return categorizedData
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
