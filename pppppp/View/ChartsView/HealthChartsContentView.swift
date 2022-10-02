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
                        .frame(height: 300)
                    Spacer(minLength: 24)
                    Text("　Weight").fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    WeightChartsUIView(data: chartsWeightItem)
                        .frame(height: 300)
                }
            }
            .navigationTitle(Text("Health"))
        }
        .onAppear {
            let task = Task {
                do {
                    chartsStepItem = try await ChartsManager.shared.createStepsChart(period: "week")
                    chartsStepItem.reverse()
                    chartsWeightItem = try await ChartsManager.shared.readWeightData()
                    chartsWeightItem.reverse()
                }
                catch {
                    
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
