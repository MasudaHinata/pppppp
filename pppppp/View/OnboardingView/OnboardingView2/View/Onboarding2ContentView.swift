import SwiftUI

struct Onboarding2ContentView: View {

    @ObservedObject var viewModel: Onboarding2ViewModel

    var body: some View {

        ZStack {
            //FIXME: 画面sizeに合わせる
            Image(asset: Asset.Assets.onboardingBackground)
                .resizable()
                .scaledToFill()
            

            VStack {
                Image(asset: Asset.Assets.onboardingVer2)
                    .resizable()
                    .scaledToFit()

                VStack (alignment: .leading) {
                    //TODO: 行間空ける
                    Text("19時以降に")
                        .font(.system(size: 24, weight: .bold, design: .rounded))

                    Text("今日の振り返りをすると")
                        .font(.system(size: 24, weight: .bold, design: .rounded))

                    Text("ポイントを獲得できます")
                        .font(.system(size: 24, weight: .bold, design: .rounded))

                    Text("19時に通知を送りますか？")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                }

                HStack {
                    Spacer()

                    Button {
//                        viewModel.getPermissionHealthKit()
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
