import SwiftUI
import Kingfisher

struct FriendRequestContentView: View {

    @ObservedObject var viewModel: FriendRequestViewModel

    var body: some View {

        let bounds = UIScreen.main.bounds
        let width = bounds.width

        List {
            VStack (alignment: .leading) {
                ForEach(viewModel.userData) { item in
                    HStack {
                        KFImage(URL(string: item.iconImageURL))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 64, height: 64)
                            .cornerRadius(32)
                        
                        Text(item.name)
                            .fontWeight(.semibold)
                            .frame(width: 104, height: 32, alignment: .leading)
                        
                        Button {
                            viewModel.sendFriendRequest(friendId: item.id ?? "")
                        } label: {
                            Text("承認")
                                .frame(width: 56, height: 24)
                                .fontWeight(.medium)
                                .background(Color(asset: Asset.Colors.white00))
                                .foregroundColor(Color(asset: Asset.Colors.mainColor))
                        }
                        
                        Button {
                            viewModel.deleteFriendRequest(friendId: item.id ?? "")
                        } label: {
                            Text("削除")
                                .frame(width: 56, height: 24)
                                .fontWeight(.medium)
                                .background(Color(asset: Asset.Colors.white48))
                                .foregroundColor(Color.white)
                        }
                    }
                    Text("")
                        .frame(height: 4)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(asset: Asset.Colors.mainColor))
        .navigationBarTitle(Text("Friend Request"))
        .onAppear() {
            viewModel.getFriendRequest()
        }
        .refreshable {
            print("refresh")
        }
    }
}
