import SwiftUI
import Charts
import Combine

struct ProfileContentView: View {
    
    @State var friendCount: Int?
    @State var point: Int?
//    @State var imrageUrl: URL
    
    var body: some View {
        
//        var imageUrl: URL
        
        NavigationView {
            ScrollView {
                
                HStack(spacing: 32) {
                    Spacer(minLength: -30)
                    
                    AsyncImage(url: URL(string: UserDefaults.standard.object(forKey: "IconImageURL") as! String))
                        .frame(width: 30, height: 30)
                    
                    Text("\(String(point ?? 0))\npoint")
                    
                    Button(action: {
                        //TODO: FriendListViewにpush遷移させる
                        
                    }){
                        Text("\((friendCount ?? 0))\nfriends")
                    }
                    .foregroundColor(.white)
                    
                    
                    Button(action: {
                        //TODO: ChangeProfileViewにpush遷移させる
                        
                    }){
                        Image(systemName: "pencil")
                        Text("Edit")
                    }
                    .foregroundColor(.white)
                    
                }
            }
            .navigationBarTitle(Text((UserDefaults.standard.object(forKey: "name") as? String) ?? ""))
            .navigationBarItems(trailing: HStack {
                //TODO: SettingViewにmodal遷移させる, Imageおく
                Button("gearshape") {}
                //TODO: ShareMyDataViewにmodal遷移させる, Imageおく
                Button("person.crop.circle.badge.plus") {}
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
