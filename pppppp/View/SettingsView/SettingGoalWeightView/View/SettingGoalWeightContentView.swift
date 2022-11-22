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
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(asset: Asset.Colors.white48))

            ZStack {
                TextField("\(viewModel.weight)", value: $viewModel.weight, formatter: NumberFormatter())
                    .font(.system(size: 14, weight: .bold))
                    .keyboardType(.decimalPad)
                    .frame(width: width * 0.8, height: 48)
                    .background(Color(asset: Asset.Colors.subPurple50))

                Text("kg")
            }

            Text("\(viewModel.weight) kg")


            Text("Enter weight goal")

            
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(asset: Asset.Colors.mainColor))
    }
}
