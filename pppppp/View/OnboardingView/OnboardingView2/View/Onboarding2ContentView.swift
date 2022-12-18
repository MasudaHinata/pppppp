import SwiftUI

struct Onboarding2ContentView: View {

    @ObservedObject var viewModel: Onboarding2ViewModel

    var body: some View {

        ZStack {
            LinearGradient(colors: [Color(asset: Asset.Colors.onboardingGradientColor1), Color(asset: Asset.Colors.onboardingGradientColor2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack {
                Image(asset: Asset.Assets.onboarding2)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 400)
                    .padding()

                Text("GET READY.")
                    .font(.system(size: 32, weight: .bold, design: .default))


                Spacer()

                Text("19時以降に今日の振り返りをするとポイントを獲得できます")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .padding()

                Spacer()

                Text("通知の送信を許可してください")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .padding()

                Button {
                    UserDefaults.standard.set(true, forKey: "initialScreen")

                    viewModel.flg = viewModel.getNotifiedPermission()
                    if viewModel.flg {
                        viewModel.dismiss()
                    }
                } label: {
                    HStack {
                        Image(systemName: "figure.walk.motion")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                        Text("Go")
                            .foregroundColor(Color(asset: Asset.Colors.white00))
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                    }
                    .padding()
                    .background(Color(asset: Asset.Colors.white48))
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

                }
            }
        }
    }
}
