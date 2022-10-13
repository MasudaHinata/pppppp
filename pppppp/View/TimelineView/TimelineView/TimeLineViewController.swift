import UIKit
import Combine

class TimeLineViewController: UIViewController {
    
    let layout = UICollectionViewFlowLayout()
    var refreshCtl = UIRefreshControl()
    var activityIndicator: UIActivityIndicatorView!
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

        layout.estimatedItemSize = CGSize(width: self.view.frame.width, height: 104)
        
        refreshCtl.tintColor = .white
        collectionView.refreshControl = refreshCtl
        refreshCtl.addAction(.init { _ in self.refresh() }, for: .valueChanged)

        activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
        activityIndicator.center = self.view.center
        activityIndicator.style = .large
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                activityIndicator.startAnimating()
                postDataItem = try await FirebaseClient.shared.getPointActivityPost()
                collectionView.reloadData()
                let friendRequestCount = try await FirebaseClient.shared.getFriendRequestCount()
                if friendRequestCount == 0 {
                    let createButton = UIBarButtonItem(image: UIImage(systemName: "bell.fill")!, style: .plain, target: self, action: #selector(didTapCreateDeckButton))
                    navigationItem.rightBarButtonItem = createButton
                    createButton.tintColor = UIColor.white
                } else {
                    let createButton = UIBarButtonItem(image: UIImage(systemName: "bell.badge.fill")!, style: .plain, target: self, action: #selector(didTapCreateDeckButton))
                    navigationItem.rightBarButtonItem = createButton
                    createButton.tintColor = UIColor.white
                }
            }
            catch {
                print("TimeLineViewContro viewDidL error:", error.localizedDescription)
                if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "インターネット接続を確認してください")
                } else {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)")
                }
            }
            activityIndicator.stopAnimating()
        }
        cancellables.insert(.init { task.cancel() })
    }

    @objc func didTapCreateDeckButton() {
        let friendRequestHostingVC = FriendRequestHostingViewController(viewModel: FriendRequestViewModel())
        self.navigationController?.pushViewController(friendRequestHostingVC, animated: true)
    }
    
    //MARK: - timelineの更新
    func refresh() {
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                postDataItem = try await FirebaseClient.shared.getPointActivityPost()
                collectionView.reloadData()
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
