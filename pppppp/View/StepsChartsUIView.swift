import SwiftUI
import Charts

@available(iOS 16.0, *)
struct StepsChartsUIView: View {

    var data: [ChartsStepItem]
    var body: some View {
        Chart {
            ForEach(data) { item in
                BarMark(
                    x: .value("Date", item.date),
                    y: .value("Step Count", item.stepCounts)
                )
            }
        }
    }
}
