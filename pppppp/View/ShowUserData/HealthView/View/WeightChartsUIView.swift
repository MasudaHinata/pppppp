import SwiftUI
import Charts

@available(iOS 16.0, *)
struct WeightChartsUIView: View {

    var data: [ChartsWeightItem]
    var body: some View {
        ZStack {
            Color(asset: Asset.Colors.mainColor)
            Chart {
                ForEach(data) { item in
                    LineMark(
                        x: .value("Date", item.date),
                        y: .value("Weight", item.weight)
                    )
                    PointMark(
                        x: .value("Date", item.date),
                        y: .value("Step Count", item.weight)
                    )
                }
            }
            .chartForegroundStyleScale([
                "weight": Color(asset: Asset.Colors.subColor)
            ])
        }
    }
}
