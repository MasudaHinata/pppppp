import UIKit
import Combine

class UserDataViewController: UIViewController, FirebaseClientDeleteFriendDelegate {
    
    var cancellables = Set<AnyCancellable>()
    var userDataItem: UserData?
    var pointDataList = [PointData]()
    var activityIndicator: UIActivityIndicatorView!
    let layout = UICollectionViewFlowLayout()
    var flag: Bool!
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var pointLabel: UILabel!
    @IBOutlet var iconView: UIImageView! {
        didSet {
            iconView.layer.cornerRadius = 36
            iconView.layer.cornerCurve = .continuous
        }
    }
    
    @IBOutlet var deleteFriendButtonLayout: UIButton!
    
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(UINib(nibName: "RecentActivitysTableViewCell", bundle: nil), forCellReuseIdentifier: "RecentActivitysTableViewCell")
            tableView.backgroundView = nil
            tableView.backgroundColor = .clear
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
    
    @IBAction func deleteFriendButton() {
        if flag {
            let alert = UIAlertController(title: "注意", message: "友達を削除しますか？", preferredStyle: .alert)
            let delete = UIAlertAction(title: "削除", style: .destructive) { [self] (action) -> Void in
                let task = Task { [weak self] in
                    guard let self = self else { return }
                    do {
                        guard let friendID = userDataItem?.id else { return }
                        try await FirebaseClient.shared.deleteFriendQuery(deleteFriendId: friendID)
                    }
                    catch {
                        print("CollectionViewContro viewDid error:",error.localizedDescription)
                        if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                            ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "インターネット接続を確認してください") { _ in
                                self.viewDidLoad()
                            }
                        } else {
                            ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)")
                        }
                    }
                }
                self.cancellables.insert(.init { task.cancel() })
            }
            let cancel = UIAlertAction(title: "キャンセル", style: .cancel) { (action) -> Void in
            }
            alert.addAction(delete)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        } else if flag == false {
            let secondVC = StoryboardScene.SettingView.initialScene.instantiate()
            self.showDetailViewController(secondVC, sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseClient.shared.deletefriendDelegate = self
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        activityIndicator.center = self.view.center
        activityIndicator.style = .large
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        iconView.kf.setImage(with: URL(string: userDataItem!.iconImageURL))
        nameLabel.text = userDataItem?.name
        pointLabel.text = "\(userDataItem?.point ?? 0)pt"
        
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                guard let friendID = userDataItem?.id else { return }
                let userID = try await FirebaseClient.shared.getUserUUID()
                if friendID == userID {
                    flag = false
                    deleteFriendButtonLayout.tintColor = Asset.Colors.purple50.color
                    deleteFriendButtonLayout.setTitleColor(.white, for: .normal)
                    deleteFriendButtonLayout.setTitle("Setting", for: .normal)
                } else {
                    flag = true
                    deleteFriendButtonLayout.tintColor = UIColor.systemPink
                    deleteFriendButtonLayout.setTitle("Delete Friend", for: .normal)
                }
                pointDataList = try await FirebaseClient.shared.getPointData(id: (userDataItem?.id)!)
                pointDataList.reverse()
                self.collectionView.reloadData()
                self.tableView.reloadData()
                activityIndicator.stopAnimating()
            }
            catch {
                print("UserDataViewContro viewDidL error:",error.localizedDescription)
                if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "インターネット接続を確認してください") { _ in
                        self.viewDidLoad()
                    }
                } else {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)")
                }
            }
        }
        self.cancellables.insert(.init { task.cancel() })
    }
    
    //MARK: - Setting Delegate
    func friendDeleted() async {
        let alert = UIAlertController(title: "完了", message: "友達を削除しました", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            let secondVC = StoryboardScene.Main.initialScene.instantiate()
            self.showDetailViewController(secondVC, sender: self)
        }
        alert.addAction(ok)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}