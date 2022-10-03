import SwiftUI
import Combine


var cancellables = Set<AnyCancellable>()
var averageStep: Int!

@available(iOS 16.0, *)
struct HealthChartsContentView: View {
    
    @State var chartsStepItem = [ChartsStepItem]()
    @State var chartsWeightItem = [ChartsWeightItem]()
    @State private var stepSelectedIndex = 0
    @State private var weightSelectedIndex = 0
    @State private var stepPeriodIndex = ["week", "month", "year"]
    @State private var weightPeriodIndex = ["week"]
    
    var body: some View {
        
        let bounds = UIScreen.main.bounds
        let width = Int(bounds.width)
        let height = Int(bounds.height)
        
        NavigationView {
            ScrollView {
                //MARK: - Step Chart
                Group {
                    Text("Step").fontWeight(.semibold)
                        .frame(maxWidth: CGFloat(width) - 32, alignment: .leading)
                    Picker("Step period", selection: self.$stepSelectedIndex) {
                        ForEach(0..<self.stepPeriodIndex.count) { index in
                            Text(self.stepPeriodIndex[index])
                                .tag(index)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(maxWidth: CGFloat(width) - 32, alignment: .center)
                    Text("平均")
                        .font(.custom("F5.6", fixedSize: 12))
                        .foregroundColor(Color(asset: Asset.Colors.white48))
                        .frame(maxWidth: CGFloat(width) - 32, alignment: .leading)
                    
                    Text("\(averageStep ?? 0) steps")
                        .font(.custom("F5.6", fixedSize: 16))
                        .frame(maxWidth: CGFloat(width) - 32, alignment: .leading)
                        .onAppear {
                            let task = Task {
                                do {
                                    let period = self.stepPeriodIndex[self.stepSelectedIndex]
                                    var averagePeriod = 0
                                    if period == "week" {
                                        averagePeriod = 6
                                    } else if period == "month" {
                                        averagePeriod = 29
                                    } else {
                                        averagePeriod = 364
                                    }
                                    averageStep = try await HealthKitManager.shared.getAverageStep(date: Double(averagePeriod))
                                }
                                catch {
                                    print("HealthChartsContentView error:", error.localizedDescription)
                                }
                            }
                            cancellables.insert(.init { task.cancel() })
                        }
                    
                    StepsChartsUIView(data: chartsStepItem)
                        .frame(maxWidth: CGFloat(width) - 32, minHeight: 300, alignment: .center)
                }
                
                Spacer(minLength: 40)
                
                //MARK: - Weight Chart
                Group {
                    Text("Weight").fontWeight(.semibold)
                        .frame(maxWidth: CGFloat(width) - 32, alignment: .leading)
                    Picker("Weight period", selection: self.$weightSelectedIndex) {
                        ForEach(0..<self.weightPeriodIndex.count) { index in
                            Text(self.weightPeriodIndex[index])
                                .tag(index)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(maxWidth: CGFloat(width) - 32, alignment: .center)
                    Spacer(minLength: 16)
                    WeightChartsUIView(data: chartsWeightItem)
                        .frame(maxWidth: CGFloat(width) - 32, minHeight: 300, alignment: .center)
                }
                
                Spacer(minLength: 40)
                
                //MARK: - Workout
                Group {
                    Text("Workout").fontWeight(.semibold)
                        .frame(maxWidth: CGFloat(width) - 32, alignment: .leading)
                    
                    
                }
            }
            .navigationTitle(Text("Health"))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(asset: Asset.Colors.mainColor))
        }
        .onAppear {
            let task = Task {
                do {
                    let period = self.stepPeriodIndex[self.stepSelectedIndex]
                    chartsStepItem = try await HealthKitManager.shared.createStepsChart(period: period)
                    chartsStepItem.reverse()
                    chartsWeightItem = try await HealthKitManager.shared.readWeightData()
                    chartsWeightItem.reverse()
                }
                catch {
                    print("HealthChartsContentView error:", error.localizedDescription)
                }
            }
            cancellables.insert(.init { task.cancel() })
        }
        .onChange(of: self.stepPeriodIndex[self.stepSelectedIndex]) { (newValue) in
            let task = Task {
                do {
                    let period = newValue
                    chartsStepItem = try await HealthKitManager.shared.createStepsChart(period: period)
                    chartsStepItem.reverse()
                }
                catch {
                    print("HealthChartsContentView error:", error.localizedDescription)
                }
            }
            cancellables.insert(.init { task.cancel() })
        }
        .onChange(of: self.stepPeriodIndex[self.stepSelectedIndex]) { (newValue) in
            let task = Task {
                do {
                    let period = newValue
                    var averagePeriod = 0
                    if period == "month" {
                        averagePeriod = 29
                    } else if period == "year" {
                        averagePeriod = 364
                    } else {
                        averagePeriod = 6
                    }
                    
                    averageStep = try await HealthKitManager.shared.getAverageStep(date: Double(averagePeriod))
                }
                catch {
                    print("HealthChartsContentView error:", error.localizedDescription)
                }
            }
            cancellables.insert(.init { task.cancel() })
        }
    }
}

