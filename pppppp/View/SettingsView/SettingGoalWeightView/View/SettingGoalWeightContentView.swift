import SwiftUI
import Lottie

struct SettingGoalWeightContentView: View {
    
    @ObservedObject var viewModel: SettingGoalWeightViewModel

    var body: some View {

        VStack {
            Spacer()

            LottieView(name: "sanitas-logo-appear", contentMode: .scaleAspectFill, loopMode: .playOnce)
                .frame(maxWidth: .infinity, maxHeight: 300)

            Spacer()

            Text("Enter weight")
                .frame(maxWidth: UIScreen.main.bounds.width * 0.85, alignment: .leading)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(asset: Asset.Colors.white48))

            ZStack {
                TextField("", value: $viewModel.weight, formatter: NumberFormatter())
                    .font(.system(size: 14, weight: .bold))
                    .keyboardType(.decimalPad)
                    .frame(width: UIScreen.main.bounds.width * 0.80, height: 48)
                    .padding(.horizontal)
                    .background(Color(asset: Asset.Colors.subPurple50))
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                Text("kg")
                    .font(.system(size: 14, weight: .bold))
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.8, alignment: .trailing)
            }

            Text("Enter weight goal")
                .frame(maxWidth: UIScreen.main.bounds.width * 0.85, alignment: .leading)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(asset: Asset.Colors.white48))

            ZStack {
                TextField("", value: $viewModel.weightGoal, formatter: NumberFormatter())
                    .font(.system(size: 14, weight: .bold))
                    .keyboardType(.decimalPad)
                    .frame(width: UIScreen.main.bounds.width * 0.80, height: 48)
                    .padding(.horizontal)
                    .background(Color(asset: Asset.Colors.subPurple50))
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                Text("kg")
                    .font(.system(size: 14, weight: .bold))
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.8, alignment: .trailing)
            }
            
            Spacer()

            Button {
                viewModel.setWeightGoal()
            } label: {
                Text("Set your goal")
                    .font(.system(size: 14, weight: .semibold))
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.85, maxHeight: 48)
            }
            .alert(isPresented: $viewModel.showingAlert) {
                switch viewModel.alertType {
                case .warning:
                    return Alert(title: Text("目標体重を入力してください"))
                case .complete:
                    return Alert(title: Text("設定しました"),
                          dismissButton: .default(Text("ok"), action: { viewModel.dismiss() }))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: UIScreen.main.bounds.width * 0.80, maxHeight: 48)
            .padding(.horizontal)
            .background(Color(asset: Asset.Colors.subColor))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            ZStack {
                Color(asset: Asset.Colors.mainColor)
                Image("blue")
                    .resizable()
                    .scaledToFill()
            }
            .ignoresSafeArea()
        }
    }
}
