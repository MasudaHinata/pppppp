import UIKit

extension FriendListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friendDataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "frienddatacell", for: indexPath)  as! FriendDataCell
        cell.nameLabel.text = friendDataList[indexPath.row].name
        cell.iconView.kf.setImage(with: URL(string: friendDataList[indexPath.row].iconImageURL)!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       let profileVC = ProfileHostingController(viewModel: .init(userDataItem: friendDataList[indexPath.row]))
        self.showDetailViewController(profileVC, sender: self)
    }
}
