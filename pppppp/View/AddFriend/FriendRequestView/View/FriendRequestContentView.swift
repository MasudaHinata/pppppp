import SwiftUI
import Kingfisher

struct FriendRequestContentView: View {

    @ObservedObject var viewModel: FriendRequestViewModel

    var body: some View {

        let bounds = UIScreen.main.bounds
        let width = bounds.width

        ScrollView {
            ForEach(viewModel.userData) { item in
                HStack (spacing: width * 0.1) {
                    KFImage(URL(string: item.iconImageURL))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 72, height: 72)
                        .cornerRadius(36)

                    Text(item.name)

                    Button {
                        //TODO: 承認送る
                    }label: {
                        Text("承認")
                            .background(Color(asset: Asset.Colors.subColor))
                            .foregroundColor(Color.white)
                    }


                    Button {
                        //TODO: 却下する
                    }label: {
                        Text("削除")
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
