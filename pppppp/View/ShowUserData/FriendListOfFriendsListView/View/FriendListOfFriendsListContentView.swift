import SwiftUI
import Kingfisher
import Combine

struct FriendListOfFriendsListContentView: View {

    @ObservedObject var viewModel: FriendListOfFriendsListViewModel
    
    var body: some View {

        NavigationView {
            Form {
                ForEach(viewModel.userData) { item in
                    HStack {
                        KFImage(URL(string: item.iconImageURL))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 56, height: 56)
                            .cornerRadius(28)

                        Text(item.name)
                            .fontWeight(.semibold)
                            .font(.headline)


                        Button {
//                            viewModel.getFriendOfFriendData(friendOfFriendId: item.id ?? "")
                            viewModel.friendIdOfFriend = item.id ?? ""

                            if (viewModel.friendData.first(where: {$0.id == item.id }) != nil) {
                                viewModel.sceneFriendProfileView()
                            } else {
                                viewModel.sceneAddFriendView()
                            }
                        } label: {
                        }
                    }
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
            .background(Color(asset: Asset.Colors.mainColor))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarTitle(Text("Friends"))
            .onAppear() {
                viewModel.getFriendListOfList()
            }
        }
        .navigationTitle("Friends")
    }
}
