import SwiftUI

struct Onboarding2ContentView: View {
    
    
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Image(asset: Asset.Assets.onboarding2)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 400)
                .padding(80)

            if #available(iOS 16.0, *) {
                Text("STAY NOTIFIED.")
                    .font(.largeTitle.width(.expanded))
                    .bold()
            } else {
                Text("STAY NOTIFIED.")
                    .font(.system(size: 32, weight: .bold, design: .default))
            }
            
            Spacer()
            
            Text("19時以降に今日の振り返りをするとポイントを獲得できます。")
                .font(.system(size: 14, weight: .bold, design: .rounded))
            
            Spacer()
            
            Text("通知の送信を許可してください。")
                .font(.system(size: 14, weight: .bold, design: .rounded))
            
            Spacer()
            
            HStack {
                Spacer()
                Button {
                    UserDefaults.standard.set(true, forKey: "initialScreen")
                    viewModel.dismiss()
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
                    .background(Color(asset: Asset.Colors.white16))
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                }
            }
        }
        .padding()
        .background(
            LinearGradient(colors: [Color(asset: Asset.Colors.onboardingGradientColor1), Color(asset: Asset.Colors.onboardingGradientColor2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
        )
    }
}
