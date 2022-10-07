//import UIKit
//import Combine
//
//extension TimelineNotificationViewController: UICollectionViewDelegate, UICollectionViewDataSource {
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 7
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimelineNotificationCollectionViewCell", for: indexPath)  as! TimelineNotificationCollectionViewCell
//
//        var cancellables = Set<AnyCancellable>()
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "YY/MM/dd hh:mm"
//
//        print(likeFriendDataList)
//        cell.friendIconView.kf.setImage(with: URL(string: likeFriendDataList[indexPath.row].iconImageURL))
//        cell.friendNameLabel.text = likeFriendDataList[indexPath.row].name
        
//        let task = Task { [weak self] in
//            guard let self = self else { return }
//            do {
//
//            }
//            catch {
//                print("TimeLineViewContro viewdid error:",error.localizedDescription)
//                if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
//                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "インターネット接続を確認してください", handler: { _ in
//                        self.viewDidAppear(true)
//                    })
//                } else {
//                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)", handler: { _ in })
//                }
//            }
//        }
//        cancellables.insert(.init { task.cancel() })
//
//        return cell
//    }
//}
