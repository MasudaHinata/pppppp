import UIKit
import Combine

class DashboardViewController: UIViewController {
    var activityIndicator: UIActivityIndicatorView!
    var friendDataList = [UserData]()
    let layout = UICollectionViewFlowLayout()
    var refreshCtl = UIRefreshControl()
    var cancellables = Set<AnyCancellable>()
    
    @IBOutlet var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.collectionViewLayout = layout
            collectionView.register(UINib(nibName: "DashBoardFriendDataCell", bundle: nil), forCellWithReuseIdentifier: "DashBoardFriendDataCell")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout.estimatedItemSize = CGSize(width: self.view.frame.width, height: 72)
        refreshCtl.tintColor = .white
        collectionView.refreshControl = refreshCtl
        refreshCtl.addAction(.init { _ in self.refresh() }, for: .valueChanged)
        
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        activityIndicator.center = self.view.center
        activityIndicator.style = .large
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                activityIndicator.startAnimating()
                try await FirebaseClient.shared.checkUserAuth()
                friendDataList = try await FirebaseClient.shared.getProfileData(includeMe: true)
                self.collectionView.reloadData()
                activityIndicator.stopAnimating()
            }
            catch {
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
    }
    
    //MARK: - 引っ張ってcollectionViewの更新する
    func refresh() {
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                friendDataList = try await FirebaseClient.shared.getProfileData(includeMe: true)
                self.collectionView.reloadData()
            }
            catch {
                print("DashboardView refresh error",error.localizedDescription)
                if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "インターネット接続を確認してください", handler: { _ in
                        self.viewDidLoad()
                    })
                } else {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)")
                }
            }
        }
        cancellables.insert(.init { task.cancel() })
        refreshCtl.endRefreshing()
    }
}
