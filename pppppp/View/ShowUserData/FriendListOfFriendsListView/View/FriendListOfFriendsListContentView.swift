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

                        Spacer()

                        if (viewModel.friendData.first(where: {$0.id == item.id }) == nil) {
                            Button {
                                viewModel.friendIdOfFriend = item.id ?? ""
                                viewModel.sceneAddFriendView()
                            } label: {
                                Image(systemName: "person.crop.circle.badge.plus")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .font(.subheadline)
                                    .foregroundColor(Color.white)
                                    .frame(width: 32, height: 32)
                            }
                        }

//                        Button {
//                            viewModel.friendIdOfFriend = item.id ?? ""
//
//                            if (viewModel.friendData.first(where: {$0.id == item.id }) != nil) {
//                                viewModel.sceneFriendProfileView()
//                                print("すでに友達")
//                            } else {
//                                viewModel.sceneAddFriendView()
//                                print("まだ追加してない")
//                            }
//                        } label: {
//                            Image(systemName: "person.crop.circle.badge.plus")
//                                .resizable()
//                                .font(.subheadline)
//                                .foregroundColor(Color.white)
//                                .frame(width: 32, height: 32)
//                        }
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
