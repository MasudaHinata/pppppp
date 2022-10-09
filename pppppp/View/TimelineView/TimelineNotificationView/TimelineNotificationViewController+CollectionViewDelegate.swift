import Foundation
import UIKit

extension TimelineNotificationViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return likedFriendDataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimelineNotificationViewCell", for: indexPath)  as! TimelineNotificationViewCell
        
        cell.friendNameLabel.text = likedFriendDataList[indexPath.row].name
        cell.friendIconView.kf.setImage(with: URL(string: likedFriendDataList[indexPath.row].iconImageURL))
        
        return cell
    }
}
