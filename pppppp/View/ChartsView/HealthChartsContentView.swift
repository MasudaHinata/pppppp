import SwiftUI
import Combine

var chartsStepItem = [ChartsStepItem]()
var chartsWeightItem = [ChartsWeightItem]()
var cancellables = Set<AnyCancellable>()

@available(iOS 16.0, *)
struct HealthChartsContentView: View {
    
    @State private var selectedIndex = 0
    
    var body: some View {
        
        let bounds = UIScreen.main.bounds
        let width = Int(bounds.width)
        let height = Int(bounds.height)
        
        NavigationView {
            ZStack {
                Color(asset: Asset.Colors.mainColor)
                    .ignoresSafeArea()
                ScrollView {
                    //MARK: - Step Chart
                    Text("Step").fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Picker("あ", selection: self.$selectedIndex) {
                        Text("Week")
                            .tag(0)
                        Text("Month")
                            .tag(1)
                        Text("Year")
                            .tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(maxWidth: CGFloat(width) - 32, alignment: .center)
                
                    StepsChartsUIView(data: chartsStepItem)
                        .frame(maxWidth: .infinity, minHeight: 300, alignment: .leading)
                    
                    Spacer(minLength: 40)
                    
                    //MARK: - Weight Chart
                    Text("　Weight").fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    WeightChartsUIView(data: chartsWeightItem)
                        .frame(maxWidth: .infinity, minHeight: 300, alignment: .leading)
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
