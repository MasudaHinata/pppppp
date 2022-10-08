import SwiftUI
import Kingfisher
import Charts
import Combine

struct ProfileContentView: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                //MARK: - profile画面
                Group {
                    HStack(alignment: .center, spacing: 32) {
                        
                        KFImage(viewModel.iconImageURL)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 72, height: 72)
                            .cornerRadius(36)
                        
                        Text("\(String(viewModel.point))\npoint")
                            .font(.custom("F5.6", fixedSize: 16))
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            //TODO: FriendListViewにpush遷移させる
                            
                        }){
                            Text("\((viewModel.friendCount))\nfriends")
                                .font(.custom("F5.6", fixedSize: 16))
                        }
                        .foregroundColor(.white)
                        
                        Button{
                            //TODO: ChangeProfileViewにmodal遷移させる
                        } label: {
                            Image(systemName: "pencil")
                            Text("Edit")
                        }
                        //TODO: textの上下に余白
                        .foregroundColor(Color(asset: Asset.Colors.white00))
                        .background(Color(asset: Asset.Colors.white48))
                    }
                }
                Form {
                    //MARK: - Streak
                    //                    Section {
                    StreakCollectionView(configuration: StreakCollectionView.Configuration(pointDataList: viewModel.pointDataList, flowLayout: viewModel.layout))
                    //                    }
                    
                    //MARK: - RecentActivity
                    Section {
                        ForEach(viewModel.pointDataList, id: \.self) { pointdataItem in
                            HStack {
                                Text(String(pointdataItem.point ?? 0))
                                Text(pointdataItem.activity ?? "")
                                //                            Text(pointdataItem.date)
                            }
                        }
                    } header: {
                        Text("RECENT ACTIVITY")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(asset: Asset.Colors.mainColor))
                
                .navigationBarTitle(Text(viewModel.name))
                .navigationBarItems(trailing: HStack {
                    //TODO: SettingViewにmodal遷移させる
                    Button("\(Image(systemName: "gearshape"))") {}
                        .foregroundColor(.white)
                    //TODO: ShareMyDataViewにmodal遷移させる
                    Button("\(Image(systemName: "person.crop.circle.badge.plus"))") {}
                        .foregroundColor(.white)
                })
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(asset: Asset.Colors.mainColor))
            .onAppear {
                viewModel.getProfileData()
            }
        }
    }
}
