import UIKit

extension UserDataViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 112
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SummaryCollectionViewCell", for: indexPath)  as! SummaryCollectionViewCell
        
        let weekday = Int(indexPath.row / 16) // 1行目は0
        let todayWeekday = Calendar.current.component(.weekday, from: Date()) - 1 // 1から始まるので揃えるために1引く
        let weekdayDelta = todayWeekday - weekday  //いくつ前の曜日か
        let weekDelta = 15 - indexPath.row % 16 //何週前か
        
        var dayForCell = Date()
        dayForCell = Calendar.current.date(byAdding: .weekOfYear, value: -weekDelta, to: dayForCell)!
        dayForCell = Calendar.current.date(byAdding: .weekday, value: -weekdayDelta, to: dayForCell)!
        let activitiesForCell = pointDataList.filter { $0.date.getZeroTime() == dayForCell.getZeroTime() }.compactMap { $0.point }
        if dayForCell.getZeroTime() > Date().getZeroTime() {
            cell.backgroundColor = Asset.Colors.white0.color
            return cell
        }
        let totalPointsForCell = activitiesForCell.reduce(0, +) // 合計
        switch totalPointsForCell {
        case 0 :
            cell.backgroundColor = Asset.Colors.white48.color
        case 1...30:
            cell.backgroundColor = Asset.Colors.grass1.color
        case 30...70:
            cell.backgroundColor = Asset.Colors.grass2.color
        case 70...100:
            cell.backgroundColor = Asset.Colors.grass3.color
        default:
            cell.backgroundColor = Asset.Colors.grass4.color
        }
        return cell
    }
}