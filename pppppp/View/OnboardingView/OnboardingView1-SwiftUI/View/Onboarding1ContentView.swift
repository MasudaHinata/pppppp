import SwiftUI

struct Onboarding1ContentView: View {

    @ObservedObject var viewModel: Onboarding1ViewModel
    
    var body: some View {

        ZStack {
            //FIXME: 画面sizeに合わせる
            Image(asset: Asset.Assets.onboardingBackground)
                .resizable()
                .scaledToFill()
            //                .frame(minWidth: UIScreen.main.bounds.width, minHeight: UIScreen.main.bounds.height)

            VStack {
                Image(asset: Asset.Assets.onboardingVer2)
                    .resizable()
                    .scaledToFit()

                VStack (alignment: .leading) {
                    //TODO: 行間空ける
                    Text("歩数・体重・ワークアウトを")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    Text("HealthKitから取得し、")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    Text("体格や生活リズムを考慮した")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    Text("努力ポイントを自動で作成")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                }

                HStack {
                    Spacer()

                    Button {
                        //                        viewModel.
                        print("next")
                    } label: {
                        HStack {

                            Text("next")
                                .foregroundColor(Color(asset: Asset.Colors.white00))
                            Image(systemName: "figure.walk.motion")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color(asset: Asset.Colors.white48))
                        .cornerRadius(30)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    }
                }
            }
        }
    }
}
