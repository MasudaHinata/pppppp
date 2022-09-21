import SwiftUI
import Charts

var data: [ChartsStepItem] = [
        
    .init(date: "9/15", stepCounts: 5000),
    .init(date: "9/16", stepCounts: 4000),
    .init(date: "9/17", stepCounts: 6000),
    .init(date: "9/18", stepCounts: 7000),
    .init(date: "9/19", stepCounts: 4000),
    .init(date: "9/20", stepCounts: 2000),
    .init(date: "9/21", stepCounts: 5000),
]

@available(iOS 16.0, *)
struct StepsChartsUIView: View {
    var body: some View {
        Chart {
//
//            let task = Task {
//                do {
//                    let aaa = try await Scorering.shared.createStepsChart()
//                    print(aaa)
//
//                }
//                catch {
//
//                }
//            }
            
            ForEach(data) { shape in
                BarMark(
                    x: .value("Shape Type", shape.date),
                    y: .value("Total Count", shape.stepCounts)
                )
            }
        }
    }
}

@available(iOS 16.0, *)
struct StepsChartsUIView_Previews: PreviewProvider {
    static var previews: some View {
        StepsChartsUIView()
    }
}
