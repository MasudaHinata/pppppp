import SwiftUI
import Charts

@available(iOS 16.0, *)
struct StepsChartsUIView: View {
    
    var data: [ChartsStepItem]
    var body: some View {
        ZStack {
            Color(asset: Asset.Colors.mainColor)
            Chart {
                ForEach(data) { item in
                    BarMark(
                        x: .value("Date", item.date),
                        y: .value("Step Count", item.stepCounts),
                        //TODO: 幅を指定する
                        //                        width:
                    )
                }
            }
            .chartForegroundStyleScale([
                "steps": Color(asset: Asset.Colors.subColor)
            ])
        }
    }
}
