import SwiftUI
import Kingfisher
import Combine

struct FriendListOfFriendsListContentView: View {

    @ObservedObject var viewModel: FriendListOfFriendsListViewModel
    
    var body: some View {

        let bounds = UIScreen.main.bounds
        let width = bounds.width

        NavigationView {
            Form {
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
