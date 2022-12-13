import SwiftUI
import Kingfisher
import Charts
import Combine

struct ProfileContentView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var renderedImage: UIImage?

    var body: some View {

        let bounds = UIScreen.main.bounds
        let width = bounds.width

        //TODO: NavigationStackにする
        NavigationView {

            //            //TODO: gradationView
            //            ZStack {
            //                Image("blue")
            //                    .resizable()
            //                    .scaledToFill()
            //            }

            Form {
                Section {
                    HStack(alignment: .center, spacing: width * 0.10) {
                        KFImage(URL(string: viewModel.meJudge ? viewModel.iconImageURLStr : viewModel.userDataItem?.iconImageURL ?? ""))
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
                            //TODO: Push遷移にする
                            if viewModel.meJudge {
                                //MARK: 自分のデータを表示する時
                                viewModel.sceneFriendList()
                            } else {
                                //MARK: 友達のデータを表示する時
                                viewModel.sceneFriendListOfFriend()
                            }
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
                                viewModel.alertType = .deleteFriendWarning
                                viewModel.showAlert = true
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(Color.red)
                            }
                            .alert(isPresented: $viewModel.showAlert) {
                                switch viewModel.alertType {
                                case .deleteFriendWarning:
                                    return Alert(title: Text("警告"),
                                                 message: Text("友達を削除しますか？"),
                                                 primaryButton: .cancel(Text("キャンセル")),
                                                 secondaryButton: .destructive(Text("削除"), action: { viewModel.friendDelete() }))
                                case .deletedFriend:
                                    return Alert(title: Text("完了"), message: Text("友達を削除しました"),
                                                 dismissButton: .default(Text("OK"), action: { viewModel.dismiss() }))
                                }
                            }
                        }
                    }
                    .listRowBackground(Color.clear)
                }

                //MARK: - sharePointView
                if viewModel.meJudge {


                    ZStack {
                        Image(asset: Asset.Assets.sanitasPointView)
                        VStack(alignment: .center) {
                            HStack {
                                KFImage(URL(string: viewModel.iconImageURLStr))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 72, height: 72)
                                    .cornerRadius(36)

                                VStack(alignment: .leading) {
                                    Text(DateToString(date: Date()))
                                        .font(.custom("F5.6", fixedSize: 14))
                                        .foregroundColor(Color(asset: Asset.Colors.white48))

                                    Text(viewModel.name)
                                        .font(.system(size: 24, weight: .semibold))
                                }

                                if #available(iOS 16.0, *) {
                                    Button {

                                        let renderer = ImageRenderer(content: self)
                                        if let image = renderer.uiImage {
                                            self.renderedImage = image
                                        }

                                        //viewModel.shareSns()

                                    } label: {
                                        Image(systemName: "square.and.arrow.up")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 24, height: 24)
                                            .foregroundColor(Color(asset: Asset.Colors.white00))
                                    }
                                }
                            }

                            //                                Button {
                            //
                            //                                    let renderer = ImageRenderer(content: self)
                            //                                    if let image = renderer.uiImage {
                            //                                        self.renderedImage = image
                            //                                    }
                            //
                            //                                    //                                    viewModel.shareSns()
                            //
                            //                                } label: {
                            //                                    Image(systemName: "square.and.arrow.up")
                            //                                        .resizable()
                            //                                        .scaledToFit()
                            //                                        .frame(width: 24, height: 24)
                            //                                        .foregroundColor(Color(asset: Asset.Colors.white00))
                            //                                }
                            //                            }

                            Text("\(viewModel.point)pt")
                                .font(.custom("F5.6", fixedSize: 40))

                        }
                    }
                    .listRowBackground(Color.clear)

                    if let renderedImage {
                        Image(uiImage: renderedImage)
                            .resizable()
                            .scaledToFill()
                    }
                }

                //MARK: - Graph
                //TODO: pointを日付ごとにしてChartsPointItemに入れる
                //                PointChartsUIView(data: viewModel.)
                //                    .frame(maxWidth: width - 48, minHeight: 280, alignment: .center)
                

                //MARK: - Streak
                Section {
                    //TODO: 端末のサイズに合わせて表示
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
            .navigationBarTitle(Text(viewModel.meJudge ? viewModel.name : viewModel.userDataItem?.name ?? ""))
            .navigationBarItems(trailing: HStack {
                if viewModel.meJudge {
                    //MARK: iOS16のみHealthChartViewに遷移するボタンを表示する
                    if #available(iOS 16.0, *) {
                        Button {
                            viewModel.sceneHealthCharts()
                        } label: {
                            Image(systemName: "heart")
                        }
                        .foregroundColor(.white)
                    }

                    Button {
                        viewModel.sceneAddFriend()
                    } label: {
                        Image(systemName: "person.crop.circle.badge.plus")
                    }
                    .foregroundColor(.white)

                    Button {
                        viewModel.sceneSetting()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .foregroundColor(.white)
                }
            })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .hideListBackgroundIfAvailable()
            .background(Color(asset: Asset.Colors.mainColor))
        }
        .onAppear {
            viewModel.getProfileData()
            UITableView.appearance().backgroundColor = Asset.Colors.mainColor.color
        }
    }
    
    func DateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        return dateFormatter.string(from: date)
    }
}

extension View {
    func hideListBackgroundIfAvailable() -> some View {
        Group {
            if #available(iOS 16.0, *) {
                self.scrollContentBackground(.hidden)
            } else {
                self
            }
        }
    }
}
