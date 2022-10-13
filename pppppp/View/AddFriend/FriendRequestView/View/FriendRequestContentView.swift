import SwiftUI
import Kingfisher

struct FriendRequestContentView: View {

    @ObservedObject var viewModel: FriendRequestViewModel

    var body: some View {

        let bounds = UIScreen.main.bounds
        let width = bounds.width

        ScrollView {
            ForEach(viewModel.userData) { item in
                HStack (spacing: width * 0.10) {
                    KFImage(URL(string: item.iconImageURL))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 64, height: 64)
                        .cornerRadius(32)

                    Text(item.name)

                    Button {
                        viewModel.sendFriendRequest(friendId: item.id ?? "")
                    }label: {
                        Text("承認")
                            .fontWeight(.semibold)
                            .padding(4)
                            .background(Color(asset: Asset.Colors.subColor))
                            .foregroundColor(Color.white)
                    }

                    Button {
                        viewModel.deleteFriendRequest(friendId: item.id ?? "")
                    }label: {
                        Text("削除")
                            .fontWeight(.semibold)
                            .padding(5)
                            .background(Color(asset: Asset.Colors.subColor))
                            .foregroundColor(Color.white)
                    }
                }
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(asset: Asset.Colors.mainColor))
        .navigationBarTitle(Text("Friend Request"))
        .onAppear() {
            viewModel.getFriendRequest()
        }
    }
}
