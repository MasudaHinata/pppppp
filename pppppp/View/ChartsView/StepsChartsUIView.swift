import SwiftUI
import Charts

@available(iOS 16.0, *)
struct StepsChartsUIView: View {
    
    var data: [ChartsStepItem]
    var body: some View {
        ZStack {
            Color(asset: Asset.Colors.mainColor)
//            Color.Asset.Colors.mainColor.color
//                .ignoresSafeArea()
            Chart {
                ForEach(data) { item in
                    BarMark(
                        x: .value("Date", item.date),
                        y: .value("Step Count", item.stepCounts)
                    )
                }
            }
            .chartForegroundStyleScale([
                "steps": Color.init(red: 146/255, green: 178/255, blue: 211/255)
            ])
        }
    }
}
