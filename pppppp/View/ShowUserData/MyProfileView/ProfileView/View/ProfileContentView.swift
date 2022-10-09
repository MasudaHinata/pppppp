import SwiftUI
import Kingfisher
import Charts
import Combine

struct ProfileContentView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State var pointDisplayData = [PointData]()
    
    var body: some View {
        NavigationView {
            //MARK: - profile画面
            Form {
                Section {
                    HStack(alignment: .center, spacing: 48) {
                        KFImage(viewModel.iconImageURL)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 72, height: 72)
                            .cornerRadius(36)

                        VStack {
                            Text("\(viewModel.point)")
                                .font(.custom("F5.6", fixedSize: 18))
                            Text("pt")
                                .font(.custom("F5.6", fixedSize: 14))
                        }

                        Button {
                            //TODO: push遷移させる
                            viewModel.sceneFriendList()
                        } label: {
                            VStack {
                                Text("\(viewModel.friendCount)")
                                    .font(.custom("F5.6", fixedSize: 18))
                                Text("friend")
                                    .font(.custom("F5.6", fixedSize: 14))
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
                                .frame(width: 24, height: 24)
                                .foregroundColor(Color(asset: Asset.Colors.white00))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .listRowBackground(Color.clear)
                }

                //MARK: - Streak
                Section {
                    StreakCollectionView(configuration: StreakCollectionView.Configuration(pointDataList: pointDisplayData))
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

            .navigationBarTitle(Text(viewModel.name))
            .navigationBarItems(trailing: HStack {
                Button {
                    viewModel.sceneShareMyData()
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
