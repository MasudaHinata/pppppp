import SwiftUI
import Kingfisher
import Charts
import Combine

struct ProfileContentView: View {

    @ObservedObject var viewModel: ProfileViewModel
    @State private var showingAlert = false
    
    var body: some View {

        let bounds = UIScreen.main.bounds
        let width = bounds.width

        NavigationView {
            Form {
                Section {
                    HStack(alignment: .center, spacing: width * 0.10) {
                        KFImage(viewModel.iconImageURL)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 72, height: 72)
                            .cornerRadius(36)

                        VStack {
                            Text("point")
                                .font(.custom("F5.6", fixedSize: 14))
                            Text("\(viewModel.point)")
                                .font(.custom("F5.6", fixedSize: 18))
                        }

                        Button {
                            //TODO: push遷移させる
                            viewModel.sceneFriendList()
                        } label: {
                            VStack {
                                Text("friend")
                                    .font(.custom("F5.6", fixedSize: 14))
                                Text("\(viewModel.friendCount)")
                                    .font(.custom("F5.6", fixedSize: 18))
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .foregroundColor(.white)

                        if viewModel.meJudge {
                            //MARK: 自分のデータを表示する時
                            Button{
                                viewModel.sceneChangeProfile()
                            } label: {
                                Image(systemName: "pencil.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(Color(asset: Asset.Colors.white00))
                            }
                            .buttonStyle(PlainButtonStyle())
                        } else {
                            //MARK: 友達のデータを表示する時
                            Button {
                                self.showingAlert = true
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(Color.red)
                            }
                            .alert(isPresented: $showingAlert) {
                                Alert(title: Text("警告"),
                                      message: Text("友達を削除しますか？"),
                                      primaryButton: .cancel(Text("キャンセル")),
                                      secondaryButton: .destructive(Text("削除"), action: { viewModel.friendDelete() }))
                            }
                        }
                    }
                    .listRowBackground(Color.clear)
                }

                //MARK: - Streak
                Section {
                    StreakCollectionView(configuration: StreakCollectionView.Configuration(pointDataList: viewModel.pointDataList))
                        .frame(width: 343.4, height: 139)
                        .listRowBackground(Color(asset: Asset.Colors.white16))
                } header: {
                    Text("STREAK")
                }

                //MARK: - RecentActivity
                Section {
                    ForEach(viewModel.pointDataList, id: \.self) { pointdataItem in
                        HStack {
                            Text(DateToString(date: pointdataItem.date))
                                .font(.custom("F5.6", fixedSize: 16))
                            Text(pointdataItem.activity ?? "")
                                .font(.system(size: 22, weight: .semibold))
                            Spacer()
                            Text("+\(pointdataItem.point ?? 0)pt")
                                .font(.custom("F5.6", fixedSize: 22))
                        }
                        .listRowBackground(Color(asset: Asset.Colors.white16))
                    }
                } header: {
                    Text("RECENT ACTIVITIES")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(asset: Asset.Colors.mainColor))

            .navigationBarTitle(Text(viewModel.meJudge ? viewModel.name : viewModel.userDataItem?.name ?? ""))

            .navigationBarItems(trailing: HStack {
                Button {
                    viewModel.sceneSetting()
                } label: {

                    Image(systemName: "gearshape")
                }
                .foregroundColor(.white)
                if viewModel.meJudge {
                    hidden()
                }
            })

//            .navigationBarItems(trailing: HStack {
//                Button {
//                    viewModel.sceneSetting()
//                } label: {
//                    Image(systemName: "gearshape")
//                }
//                .foregroundColor(.white)
//            })

            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(asset: Asset.Colors.mainColor))
            .onAppear {
                viewModel.getProfileData()
            }
        }
    }
    
    func DateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        return dateFormatter.string(from: date)
    }
}
