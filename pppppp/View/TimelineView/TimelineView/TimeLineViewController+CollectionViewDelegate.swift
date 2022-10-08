import UIKit
import Combine

extension TimeLineViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postDataItem.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimelinePostCollectionViewCell", for: indexPath)  as! TimelinePostCollectionViewCell
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YY/MM/dd hh:mm"
        
        cell.configureCell(postDataItem[indexPath.row])
        cell.timelineCollectionViewCellDelegate = self
        return cell
    }
    
    //MARK: 自分の投稿がタップされたらいいねした人を出す
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var cancellables = Set<AnyCancellable>()
        
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                let userID = try await FirebaseClient.shared.getUserUUID()
                
                if userID == postDataItem[indexPath.row].postData.userID {
                    let secondVC = StoryboardScene.TimelineNotificationView.initialScene.instantiate()
                    secondVC.postData = postDataItem[indexPath.row]
                    self.navigationController?.pushViewController(secondVC, animated: true)
                }
            }
            catch {
                print("TimelineViewContro viewdid error:",error.localizedDescription)
                if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "インターネット接続を確認してください", handler: { _ in
                        self.viewDidAppear(true)
                    })
                } else {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)")
                }
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
}
