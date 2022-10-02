import UIKit
import Combine

class FriendListViewController: UIViewController {

    var friendDataList = [UserData]()
    var refreshCtl = UIRefreshControl()
    var cancellables = Set<AnyCancellable>()
    
    @IBOutlet var friendcollectionView: UICollectionView! {
        didSet {
            friendcollectionView.delegate = self
            friendcollectionView.dataSource = self
            friendcollectionView.register(UINib(nibName: "FriendDataCell", bundle: nil), forCellWithReuseIdentifier: "frienddatacell")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        refreshCtl.tintColor = .white
        friendcollectionView.refreshControl = refreshCtl
        refreshCtl.addAction(.init { _ in self.refreshCollectionView() }, for: .valueChanged)
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: self.view.frame.width, height: 56)
        friendcollectionView.collectionViewLayout = layout
        
        let task = Task {  [weak self] in
            guard let self = self else { return }
            do {
                try await FirebaseClient.shared.checkNameData()
                try await FirebaseClient.shared.checkIconData()
                navigationItem.title = UserDefaults.standard.object(forKey: "name")! as? String
                
                friendDataList = try await FirebaseClient.shared.getProfileData(includeMe: false)
                self.friendcollectionView.reloadData()
            }
            catch {
                print("FriendListViewContro ViewDid error:",error.localizedDescription)
                if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "インターネット接続を確認してください", handler: { _ in
                        self.viewDidLoad()
                    })
                } else {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)", handler: { _ in })
                }
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    
    func refreshCollectionView() {
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                friendDataList = try await FirebaseClient.shared.getProfileData(includeMe: false)
                self.friendcollectionView.reloadData()
            }
            catch {
                print("ProfileViewContro refresh error:", error.localizedDescription)
                if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "インターネット接続を確認してください", handler: { _ in
                        self.viewDidLoad()
                    })
                } else {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)", handler: { _ in })
                }
            }
        }
        cancellables.insert(.init { task.cancel() })
        refreshCtl.endRefreshing()
    }

}
