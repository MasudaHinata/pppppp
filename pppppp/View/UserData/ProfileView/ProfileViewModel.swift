//
//  ProfileViewModel.swift
//  pppppp
//
//  Created by hinata on 2022/10/08.
//

import Foundation
import Combine

final class ProfileViewModel: ObservableObject {
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var friendCount: Int = 0
    @Published var point: Int = 0
    @Published var iconImageURL = URL(string: UserDefaults.standard.object(forKey: "IconImageURL") as! String)
    @Published var name = UserDefaults.standard.object(forKey: "name") as! String
    @Published var pointDataList = [PointData]() 
    
    init() {
    }
    
    func getProfileData() {
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                let userID = try await FirebaseClient.shared.getUserUUID()
                try await FirebaseClient.shared.checkNameData()
                try await FirebaseClient.shared.checkIconData()
                
                let friendDataList = try await FirebaseClient.shared.getProfileData(includeMe: false)
                self.friendCount = friendDataList.count
                
                pointDataList = try await FirebaseClient.shared.getPointData(id: userID)
                pointDataList.reverse()
                
//                let weekday = Int(indexPath.row / 16) // 1行目なら0になる
//                let todayWeekday = Calendar.current.component(.weekday, from: Date()) - 1 // 1から始まるので揃えるために1引く
//                let weekdayDelta = todayWeekday - weekday  //いくつ前の曜日か
//                let weekDelta = 15 - indexPath.row % 16 //何週前か
//
//                var dayForCell = Date()
//                dayForCell = Calendar.current.date(byAdding: .weekOfYear, value: -weekDelta, to: dayForCell)!
//                dayForCell = Calendar.current.date(byAdding: .weekday, value: -weekdayDelta, to: dayForCell)!
//                let activitiesForCell = pointDataList.filter { $0.date.getZeroTime() == dayForCell.getZeroTime() }.compactMap { $0.point }
//                if dayForCell.getZeroTime() > Date().getZeroTime() {
//                    cell.backgroundColor = Asset.Colors.white0.color
//
//                    return cell
//                }
//                let totalPointsForCell = activitiesForCell.reduce(0, +) // 合計
//                switch totalPointsForCell {
//                case 0 :
//                    cell.backgroundColor = Asset.Colors.white48.color
//                case 1...30:
//                    cell.backgroundColor = Asset.Colors.grass1.color
//                case 30...70:
//                    cell.backgroundColor = Asset.Colors.grass2.color
//                case 70...100:
//                    cell.backgroundColor = Asset.Colors.grass3.color
//                default:
//                    cell.backgroundColor = Asset.Colors.grass4.color
//                }
                
                let type = UserDefaults.standard.object(forKey: "accumulationType") ?? "今日までの一週間"
                self.point = try await FirebaseClient.shared.getPointDataSum(id: userID, accumulationType: type as! String)
            }
            catch {
                print("ProfileViewContro didAppear error:",error.localizedDescription)
            }
        }
        self.cancellables.insert(.init { task.cancel() })
    }
}
