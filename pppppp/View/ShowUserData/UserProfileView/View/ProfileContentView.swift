import SwiftUI
import Kingfisher
import Charts
import Combine

struct ProfileContentView: View {
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        VStack {
            Form {
                //MARK: Buttons
                if viewModel.meJudge {
                    HStack {
                        //MARK: 自分のデータを表示する時
                        Image(systemName: "waveform.path.ecg.rectangle")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color(asset: Asset.Colors.white48))
                            .cornerRadius(20)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .onTapGesture {
                                viewModel.sceneHealthCharts()
                            }

                        Spacer()

                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color(asset: Asset.Colors.white48))
                            .cornerRadius(20)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .onTapGesture {
                                if #available(iOS 16.0, *) {
                                    let renderer = ImageRenderer(content: ProfileContentView(viewModel: ProfileViewModel()))
                                    print(renderer.uiImage)
                                    if let image = renderer.uiImage {
                                        viewModel.renderedImage = image
                                    }
                                }
                                //viewModel.shareSns()
                            }
                    }
                    .listRowBackground(Color.clear)
                } else {
                    //MARK: 友達のデータを表示する時
                    HStack {
                        Spacer()

                        Button {
                            viewModel.alertType = .deleteFriendWarning
                            viewModel.showAlert = true
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(Color.red)
                                .padding()
                                .background(Color(asset: Asset.Colors.white48))
                                .cornerRadius(20)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
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
                    .listRowBackground(Color.clear)
                }

                //MARK: - sharePointView
                ZStack {
                    //Image(asset: Asset.Assets.sanitasPointView)
                    Image(asset: Asset.Assets.pointViewClear)
                        .resizable()
                        .scaledToFill()

                    VStack(alignment: .center) {
                        HStack {

                            KFImage(URL(string: viewModel.meJudge ? viewModel.iconImageURLStr : viewModel.userDataItem?.iconImageURL ?? ""))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 72, height: 72)
                                .cornerRadius(36)

                            VStack(alignment: .leading) {
                                Text(DateToString(date: Date()))
                                    .font(.custom("F5.6", fixedSize: 14))
                                    .foregroundColor(Color(asset: Asset.Colors.white48))

                                Text(viewModel.meJudge ? viewModel.name : viewModel.userDataItem?.name ?? "")
                                    .font(.system(size: 24, weight: .semibold))
                            }

                            //                                Spacer()

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
                        }

                        Text("\(viewModel.point)pt")
                            .font(.custom("F5.6", fixedSize: 40))

                    }
                }
                .listRowBackground(Color.clear)

                //MARK: Buttons
                if viewModel.meJudge {
                    HStack {
                        HStack {
                            Image(systemName: "pencil")
                                .foregroundColor(.white)
                            Text("Edit Profile")
                                .foregroundColor(Color(asset: Asset.Colors.white00))
                        }
                        .padding()
                        .background(Color(asset: Asset.Colors.white48))
                        .cornerRadius(16)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .onTapGesture {
                            viewModel.sceneChangeProfile()
                        }

                        HStack {
                            Image(systemName: "gearshape")
                                .foregroundColor(.white)
                            Text("Settings")
                                .foregroundColor(Color(asset: Asset.Colors.white00))
                        }
                        .padding()
                        .background(Color(asset: Asset.Colors.white48))
                        .cornerRadius(16)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .onTapGesture {
                            viewModel.sceneSetting()
                        }
                    }
                    .listRowBackground(Color.clear)

                    if viewModel.renderedImage != nil {
                        Image(uiImage: viewModel.renderedImage!)
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .hideListBackgroundIfAvailable()
            //FIXME: 画面サイズに合わせる
            .background(
                Image("blue")
                    .resizable()
                    .scaledToFill()
            )
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
