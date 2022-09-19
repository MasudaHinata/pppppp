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
                cell.backgroundColor = UIColor(hex: "FFFFFF", alpha: 0)
                return cell
            }
            let totalPointsForCell = activitiesForCell.reduce(0, +) // 合計
            switch totalPointsForCell {
            case 0 :
                cell.backgroundColor = UIColor(hex: "FFFFFF", alpha: 0.46)
            case 1...30:
                cell.backgroundColor = UIColor(hex: "45E1FF", alpha: 0.46)
            case 30...70:
                cell.backgroundColor = UIColor(hex: "3D83BC", alpha: 0.46)
            case 70...100:
                cell.backgroundColor = UIColor(hex: "008DDC", alpha: 0.46)
            default:
                cell.backgroundColor = UIColor(hex: "1D5CAC", alpha: 0.46)
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
    //友達を削除する
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 1 {
            //MARK: - activityGrass
        } else if collectionView.tag == 0 {
            //MARK: - friendList
            guard let deleteFriendId = friendDataList[indexPath.row].id else { return }
            let alert = UIAlertController(title: "注意", message: "友達を削除しますか？", preferredStyle: .alert)
            let delete = UIAlertAction(title: "削除", style: .destructive, handler: { [self] (action) -> Void in
                let task = Task { [weak self] in
                    guard let self = self else { return }
                    do {
                        try await FirebaseClient.shared.deleteFriendQuery(deleteFriendId: deleteFriendId)
                        friendDataList = try await FirebaseClient.shared.getProfileData(includeMe: false)
                        self.friendcollectionView.reloadData()
                    }
                    catch {
                        print("ProfileViewController collectionview error:",error.localizedDescription)
                        if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                            ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "インターネット接続を確認してください", handler: { (_) in
                                self.viewDidLoad()
                            })
                        } else {
                            ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)", handler: { (_) in })
                        }
                    }
                }
                cancellables.insert(.init { task.cancel() })
            })
            let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) -> Void in
            })
            alert.addAction(delete)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        } else {
            fatalError("collectionView Tag Invalid")
        }
        
    }
}
