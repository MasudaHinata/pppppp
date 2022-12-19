import SwiftUI
import Charts

@available(iOS 16.0, *)
struct PointChartsUIView: View {
    var data: [ChartsPointItem]

    var body: some View {
        ZStack {
            Color(asset: Asset.Colors.mainColor)
            Chart {
                ForEach(data) { item in
                    BarMark(
                        x: .value("Date", item.date),
                        y: .value("Step Count", item.point)
                    )
                }
            }
            .chartForegroundStyleScale([
                "steps": Color(asset: Asset.Colors.subColor)
            ])
        }
    }
}
