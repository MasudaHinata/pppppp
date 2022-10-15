import SwiftUI
import Combine

@available(iOS 16.0, *)
struct HealthChartsContentView: View {

    @ObservedObject var viewModel: HealthChartsViewModel
    
    @State var stepSelectedIndex = 0
    @State var newStepSelectedIndex = 0
    @State private var weightSelectedIndex = 0
    @State var stepPeriodIndex = ["week", "month", "year"]
    @State private var weightPeriodIndex = ["month", "week"]
    
    var body: some View {
        
        let bounds = UIScreen.main.bounds
        let width = bounds.width

        NavigationView {
            ScrollView {
                //MARK: - Step Chart
                Group {
                    Text("Step").fontWeight(.semibold)
                        .padding(.horizontal, 16.0)
                        .frame(maxWidth: width, alignment: .leading)
                        .foregroundColor(Color.white)

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
                        .foregroundColor(Color.white)

                    Text("\(viewModel.averageStep ?? 0) steps")
                        .font(.custom("F5.6", fixedSize: 16))
                        .frame(maxWidth: width - 48, alignment: .leading)
                        .foregroundColor(Color.white)

                    StepsChartsUIView(data: viewModel.chartsStepItem, selectedTabState: self.$newStepSelectedIndex)
                        .frame(maxWidth: width - 48, minHeight: 280, alignment: .center)
                }

                Spacer(minLength: 32)

                //MARK: - Weight Chart
                Group {
                    Text("Weight").fontWeight(.semibold)
                        .frame(maxWidth: width - 32, alignment: .leading)
                        .foregroundColor(Color.white)

                    Picker("Weight period", selection: self.$weightSelectedIndex) {
                        ForEach(0..<self.weightPeriodIndex.count) { index in
                            Text(self.weightPeriodIndex[index])
                                .tag(index)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(maxWidth: width - 32, alignment: .center)

                    HStack {
                        Text("Goal")
                            .font(.custom("F5.6", fixedSize: 14))
                            .foregroundColor(Color.white)

                        Text("\(viewModel.weightGoalStr ?? "") kg")
                            .font(.custom("F5.6", fixedSize: 16))
                            .foregroundColor(Color.white)

                        Spacer()

                        VStack (alignment: .leading){
                            Text("最新")
                                .font(.custom("F5.6", fixedSize: 12))
                                .foregroundColor(Color(asset: Asset.Colors.white48))

                            Text("\(viewModel.lastWeightStr ?? "0") kg")
                                .font(.custom("F5.6", fixedSize: 16))
                                .foregroundColor(Color.white)
                        }
                    }
                    .frame(maxWidth: width - 48, alignment: .leading)

                    WeightChartsUIView(data: viewModel.chartsWeightItem)
                        .frame(maxWidth: width - 48, minHeight:280, alignment: .center)
                }

                Spacer(minLength: 32)
            }
            .navigationBarTitle(Text("Health"))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(asset: Asset.Colors.mainColor))
            .foregroundColor(Color(asset: Asset.Colors.subColor))
        }
        .onAppear {
            let period = self.stepPeriodIndex[self.stepSelectedIndex]
            let weightPeriod = self.weightPeriodIndex[self.weightSelectedIndex]
            viewModel.getHealthData(period: period, weightPeriod: weightPeriod)
        }
        .onChange(of: self.stepPeriodIndex[self.stepSelectedIndex]) { (newValue) in
            viewModel.segmentIndexChangeStepCount(newValue: newValue)
            self.newStepSelectedIndex = self.stepSelectedIndex
        }
        .onChange(of: self.weightPeriodIndex[self.weightSelectedIndex]) { (newValue) in
            viewModel.weightSegmentIndexChanged(newValue: newValue)
        }
    }

}

