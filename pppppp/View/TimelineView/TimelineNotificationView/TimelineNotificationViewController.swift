import UIKit
import Combine

class TimelineNotificationViewController: UIViewController {

    var postData: PostDisplayData?
    let dateFormatter = DateFormatter()
    var cancellables = Set<AnyCancellable>()
    let layout = UICollectionViewFlowLayout()
    var friendDataList = [UserData]()
    
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
        dateFormatter.dateFormat = "YY/MM/dd hh:mm"
        layout.estimatedItemSize = CGSize(width: self.view.frame.width, height: 72)
        navigationItem.title = postData?.createdUser.name
        pointLabel.text = "\(postData?.postData.point ?? 0) pt"
        activityLabel.text = postData?.postData.activity
        dateLabel.text = "\(dateFormatter.string(from: postData!.postData.date))"
        userIconImageView.kf.setImage(with: URL(string: (postData?.createdUser.iconImageURL)!))

        
        let task = Task {
            do {
                likeFriendCountLabel.text = "\(try await FirebaseClient.shared.getPostLikeFriendCount(postId: postData?.postData.id ?? ""))"

                let task = Task { [weak self] in
                    guard let self = self else { return }
                    do {
                        try await FirebaseClient.shared.checkUserAuth()
                        //FIXME: postIDを取ってくる
                        if let postId = postData?.postData.id {
                            friendDataList = try await FirebaseClient.shared.getPostLikeFriend(postId: postId)
                            self.collectionView.reloadData()
                        }
                    } catch {
                        print("DashboardViewContro ViewDid error:",error.localizedDescription)
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
            } catch {
                print("TimelineNotificationViewController viewdid error:" ,error.localizedDescription)
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
}
