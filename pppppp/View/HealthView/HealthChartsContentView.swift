import SwiftUI
import Combine

var cancellables = Set<AnyCancellable>()

@available(iOS 16.0, *)
struct HealthChartsContentView: View {
    
    @State var chartsStepItem = [ChartsStepItem]()
    @State var chartsWeightItem = [ChartsWeightItem]()
    @State var workoutDataItem = [WorkoutData]()
    @State private var stepSelectedIndex = 0
    @State private var newStepSelectedIndex = 0
    @State private var weightSelectedIndex = 0
    @State private var stepPeriodIndex = ["week", "month", "year"]
    @State private var weightPeriodIndex = ["month", "week"]
    @State private var averageStep: Int!
    @State private var lastWeightStr: String!
    
    var body: some View {
        
        let bounds = UIScreen.main.bounds
        let width = bounds.width
        let height = bounds.height
        
        ScrollView {
            //MARK: - Step Chart
            Group {
                Text("Step").fontWeight(.semibold)
                    .padding(.horizontal, 16.0)
                    .frame(maxWidth: width, alignment: .leading)
                
                Picker("Step period", selection: self.$stepSelectedIndex) {
                    ForEach(0..<self.stepPeriodIndex.count) { index in
                        Text(self.stepPeriodIndex[index])
                            .tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(maxWidth: width - 32, alignment: .center)
                
                Text("平均")
                    .font(.custom("F5.6", fixedSize: 12))
                    .foregroundColor(Color(asset: Asset.Colors.white48))
                    .frame(maxWidth: width - 48, alignment: .leading)
                
                Text("\(averageStep ?? 0) steps")
                    .font(.custom("F5.6", fixedSize: 16))
                    .frame(maxWidth: width - 48, alignment: .leading)
                
                StepsChartsUIView(data: chartsStepItem, selectedTabState: self.$newStepSelectedIndex)
                    .frame(maxWidth: width - 48, minHeight: 280, alignment: .center)
            }
            
            Spacer(minLength: 32)
            
            //MARK: - Weight Chart
            Group {
                Text("Weight").fontWeight(.semibold)
                    .frame(maxWidth: width - 32, alignment: .leading)
                
                Picker("Weight period", selection: self.$weightSelectedIndex) {
                    ForEach(0..<self.weightPeriodIndex.count) { index in
                        Text(self.weightPeriodIndex[index])
                            .tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(maxWidth: width - 32, alignment: .center)
                
                Text("最新")
                    .font(.custom("F5.6", fixedSize: 12))
                    .foregroundColor(Color(asset: Asset.Colors.white48))
                    .frame(maxWidth: width - 48, alignment: .leading)
                
                Text("\(lastWeightStr ?? "0") kg")
                    .font(.custom("F5.6", fixedSize: 16))
                    .frame(maxWidth: width - 48, alignment: .leading)
                
                WeightChartsUIView(data: chartsWeightItem)
                    .frame(maxWidth: width - 48, minHeight:280, alignment: .center)
            }
            
            Spacer(minLength: 32)
            
            //MARK: - Workout
            Group {
                Text("Workout").fontWeight(.semibold)
                    .frame(maxWidth: width - 32, alignment: .leading)
                
                Spacer(minLength: 16)
                
                HStack {
                    //                    ForEach(workoutDataItem) { item in
                    //                        padding(4)
                    //                        Text(item.date)
                    ////                        Text(item.energy)
                    //                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(asset: Asset.Colors.mainColor))
        .onAppear {
            let task = Task {
                do {
                    let period = self.stepPeriodIndex[self.stepSelectedIndex]
                    var averagePeriod = 0
                    if period == "week" {
                        averagePeriod = 6
                    } else if period == "month" {
                        averagePeriod = 30
                    } else {
                        averagePeriod = 364
                    }
                    averageStep = try await HealthKit_ScoreringManager.shared.getAverageStep(date: Double(averagePeriod))
                    let stepPeriod = self.stepPeriodIndex[self.stepSelectedIndex]
                    chartsStepItem = try await HealthKit_ScoreringManager.shared.getStepsChart(period: stepPeriod)
                    chartsStepItem.reverse()
                    
                    let lastWeight = try await HealthKit_ScoreringManager.shared.getWeight()
                    lastWeightStr = String(format: "%.2f", round(lastWeight * 10) / 10)
                    chartsWeightItem = try await HealthKit_ScoreringManager.shared.getWeightData(period: self.weightPeriodIndex[self.weightSelectedIndex])
                    chartsWeightItem.reverse()
                    //TODO: chartsWeightItemが空だったらなんかする
                    //                    print(chartsWeightItem)
                    //                    if chartsWeightItem == [] {
                    //                        print("nasi")
                    //                    }
                    
                    workoutDataItem = try await HealthKit_ScoreringManager.shared.getWorkoutData()
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
                    chartsStepItem = try await HealthKit_ScoreringManager.shared.getStepsChart(period: newValue)
                    chartsStepItem.reverse()
                    self.newStepSelectedIndex = self.stepSelectedIndex
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
                    var averagePeriod = 0
                    if newValue == "month" {
                        averagePeriod = 29
                    } else if newValue == "year" {
                        averagePeriod = 364
                    } else {
                        averagePeriod = 6
                    }
                    averageStep = try await HealthKit_ScoreringManager.shared.getAverageStep(date: Double(averagePeriod))
                }
                catch {
                    print("HealthChartsContentView error:", error.localizedDescription)
                }
            }
            cancellables.insert(.init { task.cancel() })
        }
        .onChange(of: self.weightPeriodIndex[self.weightSelectedIndex]) { (newValue) in
            let task = Task {
                do {
                    chartsWeightItem = try await HealthKit_ScoreringManager.shared.getWeightData(period: newValue)
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
