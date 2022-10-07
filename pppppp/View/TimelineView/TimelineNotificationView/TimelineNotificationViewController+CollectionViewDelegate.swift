import Foundation
import UIKit

extension TimelineNotificationViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimelineNotificationViewCell", for: indexPath)  as! TimelineNotificationViewCell
        
        //FIXME: ここを呼ぶ前にTimelineNotificationViewControllerのViewDidLoadを呼びたい
        if friendDataList.isEmpty == false {
            cell.friendNameLabel.text = friendDataList[indexPath.row].name
        }
        
        
        
//        cell.friendNameLabel.text =
        
        return cell
    }
}
