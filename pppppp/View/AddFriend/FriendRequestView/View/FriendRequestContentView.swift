import SwiftUI
import Kingfisher

struct FriendRequestContentView: View {

    @ObservedObject var viewModel: FriendRequestViewModel

    var body: some View {

        let bounds = UIScreen.main.bounds
        let width = bounds.width

        ScrollView {
            VStack (alignment: .center) {

                Text("").fontWeight(.semibold)
                    .padding(.horizontal, 16.0)
                    .frame(maxWidth: width, maxHeight: 4,alignment: .leading)

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
                            viewModel.addFriend(friendId: item.id ?? "")
                        } label: {
                            Text("承認")
                                .frame(width: 56, height: 24)
                                .fontWeight(.regular)
                                .background(Color(asset: Asset.Colors.white00))
                                .foregroundColor(Color(asset: Asset.Colors.mainColor))
                        }

                        Button {
                            viewModel.deleteFriendRequest(friendId: item.id ?? "")
                        } label: {
                            Text("削除")
                                .frame(width: 56, height: 24)
                                .fontWeight(.regular)
                                .background(Color(asset: Asset.Colors.white48))
                                .foregroundColor(Color.white)
                        }
                    }
                    .alert(isPresented: $viewModel.addFriendShowAlert) {
                        Alert(title: Text("完了"), message: Text("友達を追加しました"),
                              dismissButton: .default(Text("了解"), action: { viewModel.getFriendRequest() }))
                    }
                }
            }
        }
        .background(Color(asset: Asset.Colors.mainColor))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarTitle(Text("Friend Request"))
        .onAppear() {
            viewModel.getFriendRequest()
        }
        .refreshable {
            viewModel.getFriendRequest()
        }
    }
}
