import SwiftUI
import Lottie

struct SettingGoalWeightContentView: View {

    @ObservedObject var viewModel: SettingGoalWeightViewModel

    var body: some View {

        let bounds = UIScreen.main.bounds
        let width = bounds.width
        let height = bounds.height

        VStack{
            LottieView(name: "sanitas-logo-lottie", contentMode: .scaleAspectFill, loopMode: .loop)
                .frame(width: width, height: height * 0.4)

            TextField("weight", text: $viewModel.weight)
                .keyboardType(.decimalPad)

            Text("\(viewModel.weight) KG")

            TextField("weight goal", text: $viewModel.weightGoal)
                .keyboardType(.decimalPad)

            Text("\(viewModel.weightGoal) KG")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(asset: Asset.Colors.mainColor))
    }
}
