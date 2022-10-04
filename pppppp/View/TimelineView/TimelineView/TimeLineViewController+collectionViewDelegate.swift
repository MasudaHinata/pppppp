import UIKit

extension TimeLineViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postDataItem.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimelinePostCollectionViewCell", for: indexPath)  as! TimelinePostCollectionViewCell
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YY/MM/dd hh:mm"
        dateFormatter.string(from: postDataItem[indexPath.row].date)
        
//        cell.userNameLabel.text = postDataItem[indexPath.row].name
        cell.dateLabel.text = "\(dateFormatter.string(from: postDataItem[indexPath.row].date))"
        cell.pointLabel.text = "\(postDataItem[indexPath.row].point ?? 0) pt"
        cell.activityLabel.text = postDataItem[indexPath.row].activity
        
        return cell
    }
}
