import SwiftUI

struct Onboarding1ContentView: View {

    @ObservedObject var viewModel: Onboarding1ViewModel
    
    var body: some View {

        ZStack {
            LinearGradient(colors: [Color(asset: Asset.Colors.onboardingGradientColor1), Color(asset: Asset.Colors.onboardingGradientColor2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack {
                Image(asset: Asset.Assets.onboardingVer2)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 400)

                Spacer()
                Text("歩数・体重・ワークアウトを\nHealthKitから取得し、\n体格や生活リズムを考慮した\nポイントを自動で作成します。")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .lineSpacing(24)

                HStack {
                    Spacer()

                    Button {
                        viewModel.sceneOnboarding2()
                    } label: {
                        HStack {
                            Text("next")
                                .foregroundColor(Color(asset: Asset.Colors.white00))
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                            Image(systemName: "figure.walk.motion")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        .padding()
                        .background(Color(asset: Asset.Colors.white48))
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

                    }
                }
                .padding()
            }
        }
    }
}
