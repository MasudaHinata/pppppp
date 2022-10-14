import SwiftUI
import Kingfisher
import Combine

struct FriendListOfFriendsListContentView: View {

    @ObservedObject var viewModel: FriendListOfFriendsListViewModel
    
    var body: some View {

        let bounds = UIScreen.main.bounds
        let width = bounds.width

        NavigationView {
            ScrollView {
                VStack {
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
                                viewModel.sceneAddFriendView()
                            } label: {
                                Text("追加")
                                    .frame(width: 56, height: 24)
                                    .fontWeight(.regular)
                                    .background(Color(asset: Asset.Colors.white00))
                                    .foregroundColor(Color(asset: Asset.Colors.mainColor))
                            }
                        }
                    }
                }
            }
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
