import SwiftUI
import Charts

@available(iOS 16.0, *)
struct StepsChartsUIView: View {
    
    var data: [ChartsStepItem]
    @Binding var selectedTabState: Int
    
    @State var width = 0.0
    var body: some View {
        ZStack {
            
            Color(asset: Asset.Colors.mainColor)
            Chart {
                ForEach(data) { item in
                    BarMark(
                        x: .value("Date", item.date, unit: selectedTabState == 2 ? .month : .day),
                        y: .value("Step Count", item.stepCounts)
                    )
                }
            }
            .chartForegroundStyleScale([
                "steps": Color(asset: Asset.Colors.subColor)
            ])
        }
    }
}
