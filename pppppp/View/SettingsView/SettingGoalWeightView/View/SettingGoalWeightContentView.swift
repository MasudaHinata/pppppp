import SwiftUI
import Lottie

struct SettingGoalWeightContentView: View {

    @ObservedObject var viewModel: SettingGoalWeightViewModel
    @FocusState var focus: Bool

    var body: some View {

        let bounds = UIScreen.main.bounds
        let width = bounds.width
        let height = bounds.height

        VStack {
            //TODO: アニメーションゆっくりにする
            LottieView(name: "sanitas-logo-lottie", contentMode: .scaleAspectFill, loopMode: .loop)
                .frame(width: width * 1.08, height: height * 0.6)

            Text("Enter weight")
                .frame(maxWidth: width * 0.85, alignment: .leading)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(asset: Asset.Colors.white48))

            ZStack {
                TextField("\(viewModel.weight)", value: $viewModel.weight, formatter: NumberFormatter())
                    .font(.system(size: 14, weight: .bold))
                    .keyboardType(.decimalPad)
                    .frame(width: width * 0.85, height: 48)
                    .background(Color(asset: Asset.Colors.subPurple50))
                //                    .focused(self.$focus)

                Text("kg")
                    .font(.system(size: 14, weight: .bold))
                    .frame(maxWidth: width * 0.8, alignment: .trailing)
            }

            Text("Enter weight goal")
                .frame(maxWidth: width * 0.85, alignment: .leading)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(asset: Asset.Colors.white48))

            ZStack {
                TextField("\(viewModel.weightGoal)", value: $viewModel.weightGoal, formatter: NumberFormatter())
                    .font(.system(size: 14, weight: .bold))
                    .keyboardType(.decimalPad)
                    .frame(width: width * 0.85, height: 48)
                    .background(Color(asset: Asset.Colors.subPurple50))
                //                    .focused(self.$focus)

                Text("kg")
                    .font(.system(size: 14, weight: .bold))
                    .frame(maxWidth: width * 0.8, alignment: .trailing)
            }

            Button {
                viewModel.setWeightGoal()
                print(viewModel.weight, viewModel.weightGoal)
            } label: {
                Text("setting your goal")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(.white)
            .background(Color(asset: Asset.Colors.subColor))
            .frame(width: width * 0.85, height: 48)
            .cornerRadius(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(asset: Asset.Colors.mainColor))

        //TODO: keyboard閉じる処理
        //        .onTapGesture {
        //            self.focus = false
        //        }
        //        .toolbar {
        //            ToolbarItemGroup(placement: .keyboard) {
        //                Spacer()
        //                Button("閉じる") {
        //                    focus = false
        //                }
        //            }
        //        }
    }
}
