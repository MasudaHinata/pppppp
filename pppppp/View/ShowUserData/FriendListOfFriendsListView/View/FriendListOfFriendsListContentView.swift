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
                                HStack {
                                    Image(systemName: "plus")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .foregroundColor(Color.white)
                                    //TODO: ios16に対応させる
                                        .bold()
                                        .frame(width: 14, height: 14)
                                        .padding(3)

                                    Text("ADD")
                                        .font(.system(size: 14))
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.white)
                                        .padding(4)
                                }
                                .background(Color(asset: Asset.Colors.subColor))
                                .cornerRadius(6)
                            }
                        } else {
                            Text("mutual")
                                .font(.system(size: 12))
                                .fontWeight(.semibold)
                        }
                    }
                }
                .listRowBackground(Color.clear)
            }
            //TODO: ios16に対応させる
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
