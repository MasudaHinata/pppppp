import SwiftUI
import Kingfisher
import Charts
import Combine

struct ProfileContentView: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        NavigationView {
            //MARK: - profile画面
            Form {
                Section {
                    HStack(alignment: .center, spacing: 36) {
                        KFImage(viewModel.iconImageURL)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 72, height: 72)
                            .cornerRadius(36)

                        VStack {
                            Text("\(viewModel.point)")
                                .font(.custom("F5.6", fixedSize: 18))
                            Text("pt")
                                .font(.custom("F5.6", fixedSize: 16))
                        }

                        Button {
                            //TODO: push遷移させる
                            viewModel.sceneFriendList()
                        } label: {
                            VStack {
                                Text("\(viewModel.friendCount)")
                                    .font(.custom("F5.6", fixedSize: 18))
                                Text("friends")
                                    .font(.custom("F5.6", fixedSize: 16))
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .foregroundColor(.white)

                        Button{
                            viewModel.sceneChangeProfile()
                        } label: {
                                Image(systemName: "pencil.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(Color(asset: Asset.Colors.white00))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .listRowBackground(Color.clear)
                }
                //MARK: - Streak
                Section {
                    StreakCollectionView(configuration: StreakCollectionView.Configuration(pointDataList: viewModel.pointDataList, flowLayout: viewModel.layout))
                        .frame(width: 343.4, height: 139)
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

            .navigationBarTitle(Text(viewModel.name))
            .navigationBarItems(trailing: HStack {
                Button {
                    viewModel.sceneShareMyData()
                } label: {
                    Image(systemName: "person.crop.circle.badge.plus")
                }
                .foregroundColor(.white)

                Button {
                    print("aaaa")
                    viewModel.sceneSetting()
                } label: {
                    Image(systemName: "gearshape")
                }
                .foregroundColor(.white)
            })
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
