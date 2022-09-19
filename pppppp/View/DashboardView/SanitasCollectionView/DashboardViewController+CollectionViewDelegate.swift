import UIKit

extension DashboardViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friendDataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DashBoardFriendDataCell", for: indexPath)  as! DashBoardFriendDataCell
        
        cell.nameLabel.text = friendDataList[indexPath.row].name
        cell.dataLabel.text = String(friendDataList[indexPath.row].point ?? 0)
        cell.iconView.kf.setImage(with: URL(string: friendDataList[indexPath.row].iconImageURL)!)
        return cell
    }
}
