import Kingfisher
import SwiftUI

struct ProfileCardView: View {
    @ObservedObject var viewModel: ProfileViewModel
    var body: some View {
        VStack(spacing: 0) {
            Image(asset: Asset.Assets.sanitasLogo)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 240)

            ZStack {
                Image(asset: Asset.Assets.sanitasCard)
                    .resizable()
                    .scaledToFill()

                VStack(alignment: .center) {
                    HStack {
                        ZStack {
                            Image(asset: Asset.Assets.logo)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 64, height: 64)
                                .cornerRadius(32)
                            KFImage(URL(string: viewModel.meJudge ? viewModel.iconImageURLStr : viewModel.userDataItem?.iconImageURL ?? ""))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 64, height: 64)
                                .cornerRadius(32)
                        }

                        VStack(alignment: .leading) {
                            Text(DateToString(date: Date()))
                                .font(.custom("F5.6", fixedSize: 14))
                                .foregroundColor(Color(asset: Asset.Colors.white48))

                            Text(viewModel.meJudge ? viewModel.name : viewModel.userDataItem?.name ?? "")
                                .font(.system(size: 24, weight: .semibold))
                        }

                        Spacer()

                        Button {
                            //TODO: Push遷移にする
                            if viewModel.meJudge {
                                //MARK: 自分のデータを表示する時
                                viewModel.sceneFriendList()
                            } else {
                                //MARK: 友達のデータを表示する時
                                viewModel.sceneFriendListOfFriend()
                            }
                        } label: {
                            VStack {
                                Text("friend")
                                    .font(.custom("F5.6", fixedSize: 14))
                                Text("\(viewModel.friendCount)")
                                    .font(.custom("F5.6", fixedSize: 18))
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .foregroundColor(.white)
                    }
                    .frame(maxWidth: 300)

                    Text("\(viewModel.point)pt")
                        .font(.custom("F5.6", fixedSize: 40))
                }
            }
        }
    }
    
    func DateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        return dateFormatter.string(from: date)
    }
}
