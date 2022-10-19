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

                        Spacer()

                        Button {
                            viewModel.addFriend(friendId: item.id ?? "")
                        } label: {
                            Image(systemName: "checkmark.circle")
                                .resizable()
                                .font(.subheadline)
                                .foregroundColor(Color.green.opacity(0.8))
                                .frame(width: 32, height: 32)
                        }

                        Button {
                            viewModel.deleteFriendRequest(friendId: item.id ?? "")
                        } label: {
                            Image(systemName: "xmark.circle")
                                .resizable()
                                .font(.subheadline)
                                .foregroundColor(Color.red.opacity(0.6))
                                .frame(width: 32, height: 32)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
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
