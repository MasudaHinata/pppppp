import SwiftUI


struct ProfileContentView: View {
    
    let imageUrl = URL(string: UserDefaults.standard.object(forKey: "IconImageURL") as! String)
    
    var body: some View {
        
        let bounds = UIScreen.main.bounds
        let width = Int(bounds.width)
        
        NavigationView {
            ZStack {
                Color(asset: Asset.Colors.mainColor)
                    .ignoresSafeArea()
                ScrollView {
                    AsyncImage(url: imageUrl) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 72, height: 72, alignment: .leading)
//                            .frame(maxWidth:  CGFloat(width) - 32, alignment: .leading)
                    
                    Text("STREAK")
                    Spacer(minLength: 24)
                    Text("RECENT ACTIVITYS")
                    
                    Spacer(minLength: 24)
                    
                }
            }
            //TODO: ユーザーの名前を入れる
            .navigationTitle(Text((UserDefaults.standard.object(forKey: "name")! as? String)!))
        }
        .onAppear {
            let task = Task {
                do {
                    try await FirebaseClient.shared.checkNameData()
                    try await FirebaseClient.shared.checkIconData()
//                    myNameLabel.text = UserDefaults.standard.object(forKey: "name")! as? String
//                    myIconView.kf.setImage(with: URL(string: UserDefaults.standard.object(forKey: "IconImageURL") as! String))
                }
                catch {
                    print("HealthChartsContentView error:", error.localizedDescription)
                }
            }
            cancellables.insert(.init { task.cancel() })
        }
    }
}

struct ProfileContentView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileContentView()
    }
}
