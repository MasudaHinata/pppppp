import UIKit
import Combine

extension TimeLineViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postDataItem.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimelinePostCollectionViewCell", for: indexPath)  as! TimelinePostCollectionViewCell
        
        var cancellables = Set<AnyCancellable>()
        
        cell.goodButton.isHidden = true
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YY/MM/dd hh:mm"
        
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                cell.userIconImageView.kf.setImage(with: postDataItem[indexPath.row].iconImageURL)
                cell.userNameLabel.text = postDataItem[indexPath.row].name
                cell.dateLabel.text = "\(dateFormatter.string(from: postDataItem[indexPath.row].date))"
                cell.pointLabel.text = "\(postDataItem[indexPath.row].point) pt"
                cell.activityLabel.text = postDataItem[indexPath.row].activity
                cell.likeFriendCountLabel.text = "\(try await FirebaseClient.shared.getPostLikeFriendCount(postId: postDataItem[indexPath.row].id ?? ""))"
                cell.goodButton.isHidden = false
                cell.timelineCollectionViewCellDelegate = self
            }
            catch {
                print("TimelineViewContro viewdid error:",error.localizedDescription)
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
    
    //MARK: 自分の投稿がタップされたらいいねした人を出す
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var cancellables = Set<AnyCancellable>()
        
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                let userID = try await FirebaseClient.shared.getUserUUID()
                
                if userID == postDataItem[indexPath.row].userID {
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
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)", handler: { _ in })
                }
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
}

extension TimeLineViewController: TimelineCollectionViewCellDelegate {
    
    func tapGoodButton(judge: Bool) {
        var cancellables = Set<AnyCancellable>()
        
        if judge {
            //MARK: いいねを保存する
            let task = Task { [weak self] in
                guard let self = self else { return }
                do {
                    //FIXME: postIDを取ってくる
                    let postId = "o4AsPx1um8cqzaCmlbZe"
                    try await FirebaseClient.shared.putGoodFriendsPost(postId: postId)
                }
                catch {
                    print("TimelineCollectionViewCellDelegate error:",error.localizedDescription)
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
        } else {
            //MARK: いいねを取り消す
            let task = Task { [weak self] in
                guard let self = self else { return }
                do {
                    //FIXME: postIDを取ってくる
                    let postId = "o4AsPx1um8cqzaCmlbZe"
                    try await FirebaseClient.shared.putGoodCancelFriendsPost(postId: postId)
                }
                catch {
                    print("TimelineCollectionViewCellDelegate error:",error.localizedDescription)
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
        }
        //TODO: データをキャッシュしておく, いいねが終わったらreloadData()する
//        collectionView.reloadData()
    }
}
