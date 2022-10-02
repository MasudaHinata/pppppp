import SwiftUI
import Combine

var chartsStepItem = [ChartsStepItem]()
var chartsWeightItem = [ChartsWeightItem]()
var cancellables = Set<AnyCancellable>()

@available(iOS 16.0, *)
struct HealthChartsContentView: View {
    
    @State private var stepSelectedIndex = 0
    @State private var weightSelectedIndex = 0
    @State private var periodIndex = ["week", "month", "year"]
    
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
                        .frame(maxWidth:  CGFloat(width) - 32, alignment: .leading)
                    Picker("Step period", selection: self.$stepSelectedIndex) {
                        ForEach(0..<self.periodIndex.count) { index in
                            Text(self.periodIndex[index])
                                .tag(index)
                        }
                    }
                    
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(maxWidth: CGFloat(width) - 32, alignment: .center)
                    Spacer(minLength: 16)
                    StepsChartsUIView(data: chartsStepItem)
                        .frame(maxWidth: CGFloat(width) - 32, minHeight: 300, alignment: .center)
                    
                    Spacer(minLength: 40)
                    
                    Text(self.periodIndex[self.stepSelectedIndex])
                    //                    chartsStepItem = try await ChartsManager.shared.createStepsChart(period: self.periodIndex[index])
                    //                    chartsStepItem.reverse()
                    
                    //MARK: - Weight Chart
                    Text("Weight").fontWeight(.semibold)
                        .frame(maxWidth:  CGFloat(width) - 32, alignment: .leading)
                    Picker("Weight period", selection: self.$weightSelectedIndex) {
                        ForEach(0..<self.periodIndex.count) { index in
                            Text(self.periodIndex[index])
                                .tag(index)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(maxWidth: CGFloat(width) - 32, alignment: .center)
                    Spacer(minLength: 16)
                    WeightChartsUIView(data: chartsWeightItem)
                        .frame(maxWidth: CGFloat(width) - 32, minHeight: 300, alignment: .center)
                }
            }
            .navigationTitle(Text("Health"))
        }
        //FIXME: 画面を開いた時にグラフを表示するように
        .onAppear {
            let task = Task {
                do {
                    chartsStepItem = try await ChartsManager.shared.createStepsChart(period: "week")
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
