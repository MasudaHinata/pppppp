import UIKit
import Combine

class TimelineNotificationViewController: UIViewController {
    
    var postData: PostDisplayData?
    let dateFormatter = DateFormatter()
    var cancellables = Set<AnyCancellable>()
    let layout = UICollectionViewFlowLayout()
    var likedFriendDataList = [UserData]()
    
    @IBOutlet var pointLabel: UILabel!
    @IBOutlet var activityLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var likeFriendCountLabel: UILabel!
    @IBOutlet var userIconImageView: UIImageView! {
        didSet {
            userIconImageView.layer.cornerRadius = 40
            userIconImageView.clipsToBounds = true
            userIconImageView.layer.cornerCurve = .continuous
        }
    }
    
    @IBOutlet var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.collectionViewLayout = layout
            layout.minimumLineSpacing = 0
            collectionView.register(UINib(nibName: "TimelineNotificationViewCell", bundle: nil), forCellWithReuseIdentifier: "TimelineNotificationViewCell")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = postData?.createdUser.name
        dateFormatter.dateFormat = "YY/MM/dd hh:mm"
        layout.estimatedItemSize = CGSize(width: self.view.frame.width, height: 72)
        pointLabel.text = "\(postData?.postData.point ?? 0) pt"
        activityLabel.text = postData?.postData.activity
        dateLabel.text = "\(dateFormatter.string(from: postData!.postData.date))"
        userIconImageView.kf.setImage(with: URL(string: (postData?.createdUser.iconImageURL)!))
        
        
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                //MARK: 投稿にいいねした友達と数を表示
                if let postId = postData?.postData.id {
                    likedFriendDataList = try await FirebaseClient.shared.getPostLikeFriendDate(postId: postId)
                    self.collectionView.reloadData()
                    likeFriendCountLabel.text = "\(likedFriendDataList.count)"
                }
            } catch {
                print("TimelineNotificationViewController viewdid error:",error.localizedDescription)
                if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "インターネット接続を確認してください") { _ in
                        self.viewDidLoad()
                    }
                } else {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)")
                }
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
}
