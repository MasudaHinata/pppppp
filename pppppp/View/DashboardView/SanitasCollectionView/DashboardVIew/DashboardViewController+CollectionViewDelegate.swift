import UIKit

extension DashboardViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friendDataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DashBoardFriendDataCell", for: indexPath)  as! DashBoardFriendDataCell
        cell.contentView.isUserInteractionEnabled = false
        cell.rankingLabel.text = "\(indexPath.row + 1)."
        cell.nameLabel.text = friendDataList[indexPath.row].name
        cell.dataLabel.text = "\(friendDataList[indexPath.row].point ?? 0)pt"
        cell.iconView.kf.setImage(with: URL(string: friendDataList[indexPath.row].iconImageURL)!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let profileVC = ProfileHostingController(viewModel: .init(userDataItem: friendDataList[indexPath.row]))
        self.showDetailViewController(profileVC, sender: self)
    }
}
