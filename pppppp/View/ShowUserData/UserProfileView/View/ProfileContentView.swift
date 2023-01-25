import SwiftUI
import Kingfisher
import Charts
import Combine

struct ProfileContentView: View {
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        Form {
            Section {
                ProfileHeaderView(viewModel: viewModel)
            } header: {
                Rectangle()
                    .frame(height: 0)
            }
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
        //FIXME: 色変える
        .background(
            ZStack {
                Asset.Colors.mainColor.swiftUIColor
                RadialGradient(colors: [Asset.Colors.gradientBlue1.swiftUIColor, .clear], center: .top, startRadius: 1, endRadius: UIScreen.main.bounds.width * 2)
            }.ignoresSafeArea()
        )
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
