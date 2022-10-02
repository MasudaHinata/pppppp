import SwiftUI
import Combine

var chartsStepItem = [ChartsStepItem]()
var chartsWeightItem = [ChartsWeightItem]()
var cancellables = Set<AnyCancellable>()

@available(iOS 16.0, *)
struct HealthChartsContentView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color(asset: Asset.Colors.mainColor)
                    .ignoresSafeArea()
                ScrollView {
                    Text("　Step").fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    StepsChartsUIView(data: chartsStepItem)
//                        .frame(height: 300)
                        .frame(minWidth: .infinity, minHeight: 300, alignment: .leading)
                    Spacer(minLength: 24)
                    Text("　Weight").fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    WeightChartsUIView(data: chartsWeightItem)
                        .frame(minWidth: .infinity, minHeight: 300, alignment: .leading)
                }
            }
            .navigationTitle(Text("Health"))
        }
        //FIXME: 画面を開いた時にグラフを表示するように
        .onAppear {
            let task = Task {
                do {
                    chartsStepItem = try await ChartsManager.shared.createStepsChart(period: "Y")
                    chartsStepItem.reverse()
                    chartsWeightItem = try await ChartsManager.shared.readWeightData()
                    chartsWeightItem.reverse()
                }
                catch {
                    print("HealthChartsContentView error:", error.localizedDescription)
                }
            }
            cancellables.insert(.init { task.cancel() })
        }
    }
}

@available(iOS 16.0, *)
struct HealthChartsContentView_Previews: PreviewProvider {
    static var previews: some View {
        HealthChartsContentView()
    }
}
