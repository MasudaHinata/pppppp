import UIKit

extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1 {
            return 112
        } else if collectionView.tag == 0 {
            return friendDataList.count
        } else {
            fatalError("collectionView Tag Invalid")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SummaryCollectionViewCell", for: indexPath)  as! SummaryCollectionViewCell
            
            let weekday = Int(indexPath.row / 16) // 1行目なら0になる
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
        } else if collectionView.tag == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "frienddatacell", for: indexPath)  as! FriendDataCell
            cell.nameLabel.text = friendDataList[indexPath.row].name
            cell.iconView.kf.setImage(with: URL(string: friendDataList[indexPath.row].iconImageURL)!)
            return cell
        } else {
            fatalError("collectionView Tag Invalid")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 1 {
            //MARK: - activityGrass
        } else if collectionView.tag == 0 {
            //MARK: - friendList UserDataViewに遷移
            let secondVC = StoryboardScene.UserDataView.initialScene.instantiate()
            secondVC.userDataItem = friendDataList[indexPath.row]
            self.showDetailViewController(secondVC, sender: self)
        } else {
            fatalError("collectionView Tag Invalid")
        }
    }
}
