import UIKit
import Combine
import Kingfisher

@available(iOS 16.0, *)
@MainActor
final class ProfileViewController: UIViewController, FirebaseClientDeleteFriendDelegate , FireStoreCheckNameDelegate {
    
    var completionHandlers = [() -> Void]()
    var friendDataList = [UserData]()
    var pointDataList = [PointData]()
    let layout = UICollectionViewFlowLayout()
    var cancellables = Set<AnyCancellable>()
    var refreshCtl = UIRefreshControl()
    
    @IBOutlet var myNameLabel: UILabel!
    @IBOutlet var activityBackgroundView: UIView!
    @IBOutlet var myIconView: UIImageView! {
        didSet {
            myIconView.layer.cornerRadius = 36
            myIconView.clipsToBounds = true
            myIconView.layer.cornerCurve = .continuous
        }
    }
    
    @IBOutlet var friendcollectionView: UICollectionView! {
        didSet {
            FirebaseClient.shared.deletefriendDelegate = self
            friendcollectionView.delegate = self
            friendcollectionView.dataSource = self
            friendcollectionView.register(UINib(nibName: "FriendDataCell", bundle: nil), forCellWithReuseIdentifier: "frienddatacell")
        }
    }
    
    @IBOutlet var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            layout.minimumLineSpacing = 4.5
            layout.minimumInteritemSpacing = 4.2
            collectionView.collectionViewLayout = layout
            collectionView.register(UINib(nibName: "SummaryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SummaryCollectionViewCell")
            layout.estimatedItemSize = CGSize(width: 17, height: 16)
        }
    }
    
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(UINib(nibName: "RecentActivitysTableViewCell", bundle: nil), forCellReuseIdentifier: "RecentActivitysTableViewCell")
            tableView.backgroundView = nil
            tableView.backgroundColor = .clear
        }
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "ChangeProfileView", bundle: nil)
        let secondVC = storyboard.instantiateInitialViewController()
        if let sheet = secondVC?.sheetPresentationController {
            sheet.detents = [.custom { context in 0.3 * context.maximumDetentValue }]
        }
        secondVC?.presentationController?.delegate = self
        self.present(secondVC!, animated: true, completion: nil)
    }
    
    @IBAction func sceneSettingView() {
        let storyboard = UIStoryboard(name: "SettingView", bundle: nil)
        let settingVC = storyboard.instantiateInitialViewController()
        self.showDetailViewController(settingVC ?? UIViewController(), sender: self)
    }
    
    @IBAction func scneShareMyDataView() {
        let storyboard = UIStoryboard(name: "ShareMyDataView", bundle: nil)
        let secondVC = storyboard.instantiateInitialViewController()
        self.showDetailViewController(secondVC!, sender: self)
    }
    
    @IBAction func segmentValueChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.activityBackgroundView.isHidden = false
            self.friendcollectionView.isHidden = true
        } else {
            self.activityBackgroundView.isHidden = true
            self.friendcollectionView.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseClient.shared.notChangeDelegate = self
        refreshCtl.tintColor = .white
        friendcollectionView.refreshControl = refreshCtl
        refreshCtl.addAction(.init { _ in self.refreshCollectionView() }, for: .valueChanged)
        friendcollectionView.isHidden = true
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: self.view.frame.width, height: 56)
        friendcollectionView.collectionViewLayout = layout
        
        friendDataList.removeAll()
        pointDataList.removeAll()
        
        let task = Task {  [weak self] in
            guard let self = self else { return }
            do {
                try await FirebaseClient.shared.checkNameData()
                try await FirebaseClient.shared.checkIconData()
                myNameLabel.text = UserDefaults.standard.object(forKey: "name")! as? String
                myIconView.kf.setImage(with: URL(string: UserDefaults.standard.object(forKey: "IconImageURL") as! String))
                
                let userID = try await FirebaseClient.shared.getUserUUID()
                friendDataList = try await FirebaseClient.shared.getProfileData(includeMe: false)
                pointDataList = try await FirebaseClient.shared.getPointData(id: userID)
                pointDataList.reverse()
                self.friendcollectionView.reloadData()
                self.collectionView.reloadData()
                self.tableView.reloadData()
            }
            catch {
                print("ProfileViewContro ViewDid error:",error.localizedDescription)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                try await FirebaseClient.shared.userAuthCheck()
            }
            catch {
                print("ProfileViewContro didAppear error:",error.localizedDescription)
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
    
    //MARK: - Setting Delegate
    func notChangeName() {
        let storyboard = UIStoryboard(name: "SetNameView", bundle: nil)
        let secondVC = storyboard.instantiateInitialViewController()
        self.showDetailViewController(secondVC!, sender: self)
    }
    
    func scene() {
        viewDidLoad()
    }
    func friendDeleted() {
        let alert = UIAlertController(title: "友達の削除", message: "友達を削除しました。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
