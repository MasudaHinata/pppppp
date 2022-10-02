import SwiftUI
import Charts

@available(iOS 16.0, *)
struct StepsChartsUIView: View {
    
    var data: [ChartsStepItem]
    @State var width = 0.0
    var body: some View {
        ZStack {
            Color(asset: Asset.Colors.mainColor)
            Chart {
                ForEach(data) { item in
                    BarMark(
                        x: .value("Date", item.date),
                        y: .value("Step Count", item.stepCounts)//,
//                        width: MarkDimension(floatLiteral: width / Double(data.count + 1))
                    )
                }
            }
            .chartForegroundStyleScale([
                "steps": Color(asset: Asset.Colors.subColor)
            ])
        }
//        }.background (
//            GeometryReader { geometry in
//                Color(asset: Asset.Colors.mainColor)
//                    .onAppear {
//                        width = geometry.size.width
//                    }
//            }
//        )
    }
}
