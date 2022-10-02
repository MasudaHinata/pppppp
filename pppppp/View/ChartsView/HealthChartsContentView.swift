import SwiftUI
import Combine

var chartsStepItem = [ChartsStepItem]()
var cancellables = Set<AnyCancellable>()

@available(iOS 16.0, *)
struct HealthChartsContentView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color(asset: Asset.Colors.mainColor)
                    .ignoresSafeArea()
                ScrollView {
                    StepsChartsUIView(data: chartsStepItem)
                        .frame(height: 300)
//                        .padding()
//                        .background(.ultraThinMaterial)
//                        .cornerRadius(16)
                    Text("Hello, World!")
                }
            }
            .navigationTitle(Text("Health"))
        }
        .onAppear {
            let task = Task {
                do {
                    chartsStepItem = try await ChartsManager.shared.createMonthStepsChart()
                    chartsStepItem.reverse()
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
