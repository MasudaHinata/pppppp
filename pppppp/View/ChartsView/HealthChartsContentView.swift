import SwiftUI
import Combine


var cancellables = Set<AnyCancellable>()
var averageStep: Int = 0

@available(iOS 16.0, *)
struct HealthChartsContentView: View {
    
    @State var chartsStepItem = [ChartsStepItem]()
    @State var chartsWeightItem = [ChartsWeightItem]()
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
                        .frame(maxWidth: CGFloat(width) - 32, alignment: .leading)
                    Picker("Step period", selection: self.$stepSelectedIndex) {
                        ForEach(0..<self.periodIndex.count) { index in
                            Text(self.periodIndex[index])
                                .tag(index)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(maxWidth: CGFloat(width) - 32, alignment: .center)
                    
                    
                    Text("平均")
                        .font(.custom("F5.6", fixedSize: 12))
                        .foregroundColor(Color(asset: Asset.Colors.white48))
                        .frame(maxWidth: CGFloat(width) - 32, alignment: .leading)
                    
                    Text("\(averageStep) steps")
                        .font(.custom("F5.6", fixedSize: 16))
                        .frame(maxWidth: CGFloat(width) - 32, alignment: .leading)
                    
                    StepsChartsUIView(data: chartsStepItem)
                        .frame(maxWidth: CGFloat(width) - 32, minHeight: 300, alignment: .center)
                    
                    Spacer(minLength: 40)
                    
                    //MARK: - Weight Chart
                    Text("Weight").fontWeight(.semibold)
                        .frame(maxWidth: CGFloat(width) - 32, alignment: .leading)
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
        .onAppear {
            let task = Task {
                do {
                    let period = self.periodIndex[self.stepSelectedIndex]
                    chartsStepItem = try await HealthKitManager.shared.createStepsChart(period: period)
                    chartsStepItem.reverse()
                    chartsWeightItem = try await HealthKitManager.shared.readWeightData()
                    chartsWeightItem.reverse()
                    averageStep = try await HealthKitManager.shared.getAverageStep(date: 6)
                }
                catch {
                    print("HealthChartsContentView error:", error.localizedDescription)
                }
            }
            cancellables.insert(.init { task.cancel() })
        }
        .onChange(of: self.periodIndex[self.stepSelectedIndex]) { (newValue) in
            let task = Task {
                do {
                    let period = newValue
                    chartsStepItem = try await HealthKitManager.shared.createStepsChart(period: period)
                }
                catch {
                    print("HealthChartsContentView error:", error.localizedDescription)
                }
            }
            cancellables.insert(.init { task.cancel() })
        }
    }
}

