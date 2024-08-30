import Api
import Charts
import SwiftUI

struct StatisticView: View {
    @Binding var stat: Stat
}

extension StatisticView {
    var body: some View {
        VStack {
            HStack {
                Text("Statistics")
                    .font(Font.custom("YoungSerif-Regular", size: 24))
                    .padding()
                Spacer()
            }
            
            HStack {
                CustomChart(stat: stat)
//                    .frame(width: UIScreen.main.bounds.width * 0.6)
                
                Legend(stat: stat)
//                    .frame(width: UIScreen.main.bounds.width * 0.5)
            }
        }
        .padding(.horizontal, 8)
    }

    @ViewBuilder
    func CustomChart(stat: Stat) -> some View {
        Chart(stat.statByCategories) { category in
            SectorMark(
                angle: .value("Amount", category.sum),
                innerRadius: .ratio(0.8),
                outerRadius: .inset(10)
            )
            .foregroundStyle(.black)
        }.overlay(
            Text("\(stat.total, specifier: "%.0f") ₽")
                .bold()
                .foregroundColor(.black)
        )
    }

    @ViewBuilder
    func Legend(stat: Stat) -> some View {
        VStack {
            ForEach(stat.statByCategories, id: \.id) { category in
                CategoryLabel(
                    category.categoryName,
                    category.sum,
                    .random
                )
            }
        }
    }

    @ViewBuilder
    func CategoryLabel(_ category: String, _ amount: Double, _ color: Color) -> some View {
        HStack {
            Text("\(category) \(amount, specifier: "%.0f") ₽")
                .foregroundColor(.white)
                .padding(8)
        }
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

private func sortedCategory(spends: [Spends]) -> [(String, Double, Color)] {
    var categoryTotals: [String: Double] = [:]

    for spend in spends {
        categoryTotals[spend.category.name, default: 0.0] += spend.amount
    }

    let sortedCategoryTotals = categoryTotals.sorted(by: { $0.key < $1.key })
    var categorizedData: [(String, Double, Color)] = []
    for (category, total) in sortedCategoryTotals {
        let randomColor = Color.random
        categorizedData.append((category, total, randomColor))
    }

    return categorizedData
}

//#Preview {
//    StatisticView(spends:
//        .constant(
//            preveiwSpends
//        )
//    )
//}
