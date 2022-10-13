import SwiftUI
import Kingfisher

struct FriendRequestContentView: View {

    @ObservedObject var viewModel: FriendRequestViewModel

    var body: some View {

        ScrollView {

//            ForEach(viewModel.userData) { item in
//                HStack {
//                    KFImage(URL(string: item.iconImageURL))
//                        .resizable()
//                        .scaledToFill()
//                        .frame(width: 72, height: 72)
//                        .cornerRadius(36)
//
//                    Text(item.name)
//
//                }
//            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(asset: Asset.Colors.mainColor))
        .navigationBarTitle(Text("Friend Request"))
        .onAppear() {
            viewModel.getFriendRequest()
        }
    }
}
//?? "https://firebasestorage.googleapis.com/v0/b/healthcare-58d8a.appspot.com/o/posts%2F64f3736430fc0b1db5b4bd8cdf3c9325.jpg?alt=media&token=abb0bcde-770a-47a1-97d3-eeed94e59c11"
//?? "名称未設定"
