import UIKit
import Combine

class TimelineNotificationViewController: UIViewController {

    var postData: PostDisplayData?
    let dateFormatter = DateFormatter()
    var cancellables = Set<AnyCancellable>()
    let layout = UICollectionViewFlowLayout()
    var likeFriendDataList = [UserData]()
    
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
    
//    @IBOutlet var collectionView: UICollectionView! {
//        didSet {
//            collectionView.delegate = self
//            collectionView.dataSource = self
//            collectionView.collectionViewLayout = layout
//            layout.minimumLineSpacing = 0
//            collectionView.register(UINib(nibName: "TimelineNotificationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TimelineNotificationCollectionViewCell")
//        }
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "YY/MM/dd hh:mm"
        layout.estimatedItemSize = CGSize(width: self.view.frame.width, height: 72)
        navigationItem.title = postData?.name
        pointLabel.text = "\(postData?.point ?? 0) pt"
        activityLabel.text = postData?.activity
        dateLabel.text = "\(dateFormatter.string(from: postData!.date))"
        userIconImageView.kf.setImage(with: postData?.iconImageURL)

        
        let task = Task {
            do {
                likeFriendCountLabel.text = "\(try await FirebaseClient.shared.getPostLikeFriendCount(postId: postData?.id ?? ""))"
//                likeFriendDataList = try await FirebaseClient.shared.getPostLikeFriend(postId: postData?.id ?? "")
//                collectionView.reloadData()
//                likeFriendDataList = try await FirebaseClient.shared.getProfileData(includeMe: true)
//                print(likeFriendDataList)
//                self.collectionView.reloadData()
            }
            catch {
                print("TimelineNotificationViewController viewdid error:" ,error.localizedDescription)
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
}
