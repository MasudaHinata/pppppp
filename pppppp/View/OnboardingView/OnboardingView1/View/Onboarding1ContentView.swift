import SwiftUI

struct Onboarding1ContentView: View {

    @ObservedObject var viewModel: Onboarding1ViewModel
    
    var body: some View {

        ZStack {
            LinearGradient(colors: [Color(asset: Asset.Colors.onboardingGradientColor1), Color(asset: Asset.Colors.onboardingGradientColor2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack {
                Image(asset: Asset.Assets.onboarding1)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 400)
                    .padding()

                Text("GET READY.")
                    .font(.system(size: 32, weight: .bold, design: .default))

                Spacer()
                Text("歩数・体重・ワークアウトをHealthKitから取得して体格や生活リズムを考慮したポイントを自動で作成します。")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .padding()

                Spacer()

                Text("Health Kit への書き込みと読み込みを全て許可してください。")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .padding()

                Button {
                    viewModel.getPermissionHealthKit()
//                    viewModel.sceneOnboarding2()
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
