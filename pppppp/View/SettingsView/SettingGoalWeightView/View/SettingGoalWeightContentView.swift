import SwiftUI
import Lottie

struct SettingGoalWeightContentView: View {

    @ObservedObject var viewModel: SettingGoalWeightViewModel
//    @FocusState var focus: Bool

    var body: some View {

        let bounds = UIScreen.main.bounds
        let width = bounds.width
        let height = bounds.height

        VStack {
            //TODO: アニメーションゆっくりにする
            LottieView(name: "sanitas-logo-lottie", contentMode: .scaleAspectFill, loopMode: .loop)
                .frame(width: width * 1.1, height: height * 0.6)

            Text("Enter weight")
                .frame(maxWidth: width * 0.8, alignment: .leading)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(asset: Asset.Colors.white48))

            ZStack {
                TextField("\(viewModel.weight)", value: $viewModel.weight, formatter: NumberFormatter())
                    .font(.system(size: 14, weight: .bold))
                    .keyboardType(.decimalPad)
                    .frame(width: width * 0.8, height: 48)
                    .background(Color(asset: Asset.Colors.subPurple50))

                Text("kg")
                    .font(.system(size: 14, weight: .bold))
                    .frame(maxWidth: width * 0.8, alignment: .leading)
            }

            Text("Enter weight goal")
                .frame(maxWidth: width * 0.9, alignment: .leading)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(asset: Asset.Colors.white48))

            ZStack {
                TextField("\(viewModel.weightGoal)", value: $viewModel.weightGoal, formatter: NumberFormatter())
                    .font(.system(size: 14, weight: .bold))
                    .keyboardType(.decimalPad)
                    .frame(width: width * 0.8, height: 48)
                    .background(Color(asset: Asset.Colors.subPurple50))

                Text("kg")
                    .frame(maxWidth: width * 0.8, alignment: .leading)
                    .font(.system(size: 14, weight: .bold))
            }

            
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(asset: Asset.Colors.mainColor))
    }
}
