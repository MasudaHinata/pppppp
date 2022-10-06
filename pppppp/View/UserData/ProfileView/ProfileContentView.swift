import SwiftUI
import Charts
import Combine

struct ProfileContentView: View {
    
    @State var friendCount: Int?
    @State var point: Int?
    @State private var show: Bool = false
    
    var body: some View {
        
        NavigationView {
            ScrollView {
                //MARK: - profile画面
                Group {
                    HStack(alignment: .center, spacing: 32) {
                        //                    Spacer()
                        //FIXME: 画像が大きくなっちゃう
                        //                    AsyncImage(url: URL(string: UserDefaults.standard.object(forKey: "IconImageURL") as! String))
                        //                        .frame(width: 72, height: 72)
                        
                        Text("\(String(point ?? 0))\npoint")
                            .font(.custom("F5.6", fixedSize: 16))
                        
                        Button(action: {
                            //TODO: FriendListViewにpush遷移させる
                            
                        }){
                            Text("\((friendCount ?? 0))\nfriends")
                                .font(.custom("F5.6", fixedSize: 16))
                        }
                        .foregroundColor(.white)
                        
                        Button(action: {
                            //TODO: ChangeProfileViewにmodal遷移させる
                        }){
                            Image(systemName: "pencil")
                            Text("Edit")
                        }
                        .foregroundColor(.white)
                        .background(Color(asset: Asset.Colors.white48))
                        
                        //FIXME: 空白16空ける
                    }
                }
                
                
                //MARK: - Streak
                Group {
                    
                }
                
                //MARK: - RecentActivity
                Group {
                    
                }
            }
            .navigationBarTitle(Text((UserDefaults.standard.object(forKey: "name") as? String) ?? ""))
            .navigationBarItems(trailing: HStack {
                //TODO: SettingViewにmodal遷移させる
                Button("\(Image(systemName: "gearshape"))") {}
                    .foregroundColor(.white)
                //TODO: ShareMyDataViewにmodal遷移させる
                Button("\(Image(systemName: "person.crop.circle.badge.plus"))") {}
                    .foregroundColor(.white)
            })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(asset: Asset.Colors.mainColor))
        }
        .onAppear {
            let task = Task {
                do {
                    let userID = try await FirebaseClient.shared.getUserUUID()
                    try await FirebaseClient.shared.checkNameData()
                    try await FirebaseClient.shared.checkIconData()
                    
                    let friendDataList = try await FirebaseClient.shared.getProfileData(includeMe: false)
                    friendCount = friendDataList.count
                    
                    let type = UserDefaults.standard.object(forKey: "accumulationType") ?? "今日までの一週間"
                    point = try await FirebaseClient.shared.getPointDataSum(id: userID, accumulationType: type as! String)
                }
                catch {
                    print("ProfileViewContro didAppear error:",error.localizedDescription)
                }
            }
            cancellables.insert(.init { task.cancel() })
            
            //                    myIconView.kf.setImage(with: URL(string: UserDefaults.standard.object(forKey: "IconImageURL") as! String))
        }
    }
}

//struct SecondContentView:View{
//    var body: some View {
//        Text("second")
//    }
//}

//                    Button(action: { self.show.toggle() }) {
//                        Text("画面遷移Present").fontWeight(.bold).font(.largeTitle)
//                    }
//                    .sheet(isPresented: self.$show) {
//                        // trueになれば下からふわっと表示
//                        SecondContentView()
//                    }
//                    NavigationLink(
//                        destination: SecondContentView(),
//                        label: {
//                            Text("Next")
//                        }
//                    )
