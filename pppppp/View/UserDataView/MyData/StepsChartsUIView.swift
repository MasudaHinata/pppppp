import SwiftUI
import Charts

@available(iOS 16.0, *)
struct StepsChartsUIView: View {
    
    var data: [ChartsStepItem]
    var body: some View {
        ZStack {
            Color.init(red: 18/255, green: 0/255, blue: 76/255)
                .ignoresSafeArea()
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
}
