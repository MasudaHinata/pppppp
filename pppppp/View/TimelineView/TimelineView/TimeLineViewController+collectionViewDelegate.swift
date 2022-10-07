import UIKit

extension TimeLineViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postDataItem.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimelinePostCollectionViewCell", for: indexPath)  as! TimelinePostCollectionViewCell
        
        cell.goodButton.isHidden = true
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YY/MM/dd hh:mm"
        var userID: String?
        dateFormatter.string(from: postDataItem[indexPath.row].date)
        
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                userID = try await FirebaseClient.shared.getUserUUID()
                
                if postDataItem[indexPath.row].userID == userID {
                    cell.userIconImageView.kf.setImage(with: postDataItem[indexPath.row].iconImageURL)
                    cell.userNameLabel.text = postDataItem[indexPath.row].name
                    cell.dateLabel.text = "\(dateFormatter.string(from: postDataItem[indexPath.row].date))"
                    cell.pointLabel.text = "\(postDataItem[indexPath.row].point) pt"
                    cell.activityLabel.text = postDataItem[indexPath.row].activity
                } else {
                    cell.userIconImageView.kf.setImage(with: postDataItem[indexPath.row].iconImageURL)
                    cell.userNameLabel.text = postDataItem[indexPath.row].name
                    cell.dateLabel.text = "\(dateFormatter.string(from: postDataItem[indexPath.row].date))"
                    cell.pointLabel.text = "\(postDataItem[indexPath.row].point) pt"
                    cell.activityLabel.text = postDataItem[indexPath.row].activity
                    cell.timelineCollectionViewCellDelegate = self
                    cell.goodButton.isHidden = false
                }
            }
            catch {
                print("TimeLineViewContro viewdid error:",error.localizedDescription)
                if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "インターネット接続を確認してください", handler: { _ in
                        self.viewDidAppear(true)
                    })
                } else {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)", handler: { _ in })
                }
            }
        }
        cancellables.insert(.init { task.cancel() })
        
        return cell
    }
}
