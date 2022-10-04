import UIKit

extension TimeLineViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postDataItem.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimelinePostCollectionViewCell", for: indexPath)  as! TimelinePostCollectionViewCell
        
//        cell.userNameLabel.text = postDataItem[indexPath.row].name
        cell.dateLabel.text = "\(postDataItem[indexPath.row].date)"
        cell.pointLabel.text = "\(postDataItem[indexPath.row].point ?? 0) pt"
        cell.activityLabel.text = postDataItem[indexPath.row].activity
        
        return cell
    }
}
