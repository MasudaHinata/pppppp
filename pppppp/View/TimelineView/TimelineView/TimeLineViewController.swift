import UIKit
import Combine
import Lottie

class TimeLineViewController: UIViewController {
    
    let layout = UICollectionViewFlowLayout()
    var refreshCtl = UIRefreshControl()
    var activityIndicator: LottieAnimationView!
    var postDataItem = [PostDisplayData]()
    var cancellables = Set<AnyCancellable>()
    
    @IBOutlet var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.collectionViewLayout = layout
            layout.minimumLineSpacing = 0
            collectionView.register(UINib(nibName: "TimelinePostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TimelinePostCollectionViewCell")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        layout.estimatedItemSize = CGSize(width: self.view.frame.width, height: 142)
        
        refreshCtl.tintColor = .white
        collectionView.refreshControl = refreshCtl
        refreshCtl.addAction(.init { _ in self.refresh() }, for: .valueChanged)

        activityIndicator = LottieAnimationView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        activityIndicator.center = self.view.center
        activityIndicator.animation = LottieAnimation.named("sanitas-logo-lottie")
        activityIndicator.loopMode = .loop
        activityIndicator.isHidden = true

        self.view.addSubview(activityIndicator)

        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                activityIndicator.isHidden = false
                activityIndicator.play()
                let friendRequestCount = try await FirebaseClient.shared.getFriendRequestCount()
                var buttonImage: String
                if friendRequestCount == 0 {
                    buttonImage = "bell"
                } else {
                    buttonImage = "bell.badge.fill"
                }

                let button1: UIBarButtonItem = UIBarButtonItem.init(
                    image: UIImage(systemName: buttonImage),
                    style: UIBarButtonItem.Style.plain,
                    target: self,
                    action: #selector(didTapFriendRequestButton))
                button1.tintColor = UIColor.white

                let button2 = UIBarButtonItem.init(
                    image: UIImage(systemName: "person.crop.circle.badge.plus"),
                    style: UIBarButtonItem.Style.plain,
                    target: self,
                    action: #selector(didTapAddFriendButton))
                button2.tintColor = UIColor.white
                self.navigationItem.rightBarButtonItems = [button1, button2]


                postDataItem = try await FirebaseClient.shared.getPointActivityPost()
                collectionView.reloadData()
            }
            catch {
                print("TimeLineViewContro viewDidL error:", error.localizedDescription)
                if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "インターネット接続を確認してください")
                } else {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)")
                }
            }
            activityIndicator.stop()
            activityIndicator.isHidden = true
        }
        cancellables.insert(.init { task.cancel() })
    }

    @objc func didTapFriendRequestButton() {
        let friendRequestHostingVC = FriendRequestHostingViewController(viewModel: FriendRequestViewModel())
        self.navigationController?.pushViewController(friendRequestHostingVC, animated: true)
    }

    @objc func didTapAddFriendButton() {
        let shareMyDataViewController = StoryboardScene.ShareMyDataView.initialScene.instantiate()
        self.present(shareMyDataViewController, animated: true)
    }
    
    //MARK: - timelineの更新
    func refresh() {
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                postDataItem = try await FirebaseClient.shared.getPointActivityPost()
                collectionView.reloadData()
                let friendRequestCount = try await FirebaseClient.shared.getFriendRequestCount()
                var buttonImage: String
                if friendRequestCount == 0 {
                    buttonImage = "bell"
                } else {
                    buttonImage = "bell.badge.fill"
                }

                let button1: UIBarButtonItem = UIBarButtonItem.init(
                    image: UIImage(systemName: buttonImage),
                    style: UIBarButtonItem.Style.plain,
                    target: self,
                    action: #selector(didTapFriendRequestButton))
                button1.tintColor = UIColor.white

                let button2 = UIBarButtonItem.init(
                    image: UIImage(systemName: "person.crop.circle.badge.plus"),
                    style: UIBarButtonItem.Style.plain,
                    target: self,
                    action: #selector(didTapAddFriendButton))
                button2.tintColor = UIColor.white
                self.navigationItem.rightBarButtonItems = [button1, button2]
            }
            catch {
                print("TimeLineViewContro refresh error:",error.localizedDescription)
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
        refreshCtl.endRefreshing()
    }
}
