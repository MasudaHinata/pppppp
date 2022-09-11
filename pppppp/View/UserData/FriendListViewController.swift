import UIKit
import Combine
import Kingfisher

@MainActor
final class FriendListViewController: UIViewController, FirebaseClientDeleteFriendDelegate , FireStoreCheckNameDelegate {
    
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
            myIconView.layer.cornerRadius = 32
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
            layout.minimumLineSpacing = 4.42
            layout.minimumInteritemSpacing = 4.06
            collectionView.collectionViewLayout = layout
            collectionView.register(UINib(nibName: "SummaryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SummaryCollectionViewCell")
            layout.estimatedItemSize = CGSize(width: 17.67, height: 16.24)
        }
    }
    
    @IBOutlet var profileBackgroundView: UIView! {
        didSet {
            profileBackgroundView.layer.cornerRadius = 40
            profileBackgroundView.layer.masksToBounds = true
            profileBackgroundView.layer.cornerCurve = .continuous
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
    
    @IBAction func shareButtonPressed() {
        showShareSheet()
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "ChangeProfileView", bundle: nil)
        let modalViewController = storyboard.instantiateViewController(withIdentifier: "ChangeProfileViewController") as! ChangeProfileViewController
        modalViewController.presentationController?.delegate = self
        present(modalViewController, animated: true, completion: nil)
    }
    
    @IBAction func settingButtonPressed() {
        let storyboard = UIStoryboard(name: "SettingView", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "SettingViewController")
        self.showDetailViewController(secondVC, sender: self)
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
        layout.itemSize = CGSize(width: self.view.frame.width, height: 80)
        friendcollectionView.collectionViewLayout = layout
        
        friendDataList.removeAll()
        pointDataList.removeAll()
        
        let task = Task {
            do {
                try await FirebaseClient.shared.checkNameData()
                try await FirebaseClient.shared.checkIconData()
                myNameLabel.text = UserDefaults.standard.object(forKey: "name")! as? String
                myIconView.kf.setImage(with: URL(string: UserDefaults.standard.object(forKey: "IconImageURL") as! String))
            
                let userID = try await FirebaseClient.shared.getUserUUID()
                //FIXME: 並列処理にしたい
                friendDataList = try await FirebaseClient.shared.getProfileData(includeMe: false)
                pointDataList = try await FirebaseClient.shared.getPointData(id: userID)
                pointDataList.reverse()
                self.friendcollectionView.reloadData()
                self.collectionView.reloadData()
                self.tableView.reloadData()
            }
            catch {
                let alert = UIAlertController(title: "エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                    self.viewDidLoad()
                }
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
                print("FriendListViewContro ViewDid error:",error.localizedDescription)
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
                let alert = UIAlertController(title: "エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                    self.viewDidLoad()
                }
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
                print("friendlistView didAppear error:",error.localizedDescription)
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    
    func showShareSheet() {
        let task = Task {
            do {
                let userID = try await FirebaseClient.shared.getUserUUID()
                let shareWebsite = URL(string: "sanitas-ios-dev://?id=\(userID)")!
                let activityVC = UIActivityViewController(activityItems: [shareWebsite], applicationActivities: nil)
                present(activityVC, animated: true, completion: nil)
            } catch {
                let alert = UIAlertController(title: "エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                    self.viewDidLoad()
                }
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
                print("FriendListViewContro showShareSheet:",error.localizedDescription)
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    
    func refreshCollectionView() {
        let task = Task { [weak self] in
            do {
                friendDataList = try await FirebaseClient.shared.getProfileData(includeMe: false)
                self!.friendcollectionView.reloadData()
            }
            catch {
                let alert = UIAlertController(title: "エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                    self!.viewDidLoad()
                }
                alert.addAction(ok)
                self!.present(alert, animated: true, completion: nil)
                print("FreindListViewContro refresh error:", error.localizedDescription)
            }
        }
        cancellables.insert(.init { task.cancel() })
        refreshCtl.endRefreshing()
    }
    
    //MARK: - Setting Delegate
    func notChangeName() {
        let storyboard = UIStoryboard(name: "SetNameView", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "SetNameViewController")
        self.showDetailViewController(secondVC, sender: self)
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

//MARK: - extension
extension FriendListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1 {
            return 112
        } else if collectionView.tag == 0 {
            return friendDataList.count
        } else {
            fatalError("collectionView Tag Invalid")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SummaryCollectionViewCell", for: indexPath)  as! SummaryCollectionViewCell
            
            let weekday = Int(indexPath.row / 16) // 1行目なら0になる
            let todayWeekday = Calendar.current.component(.weekday, from: Date()) - 1 // 1から始まるので揃えるために1引く
            let weekdayDelta = todayWeekday - weekday  //いくつ前の曜日か
            let weekDelta = 15 - indexPath.row % 16 //何週前か
            
            var dayForCell = Date()
            dayForCell = Calendar.current.date(byAdding: .weekOfYear, value: -weekDelta, to: dayForCell)!
            dayForCell = Calendar.current.date(byAdding: .weekday, value: -weekdayDelta, to: dayForCell)!
            let activitiesForCell = pointDataList.filter { $0.date.getZeroTime() == dayForCell.getZeroTime() }.compactMap { $0.point }
            if dayForCell.getZeroTime() > Date().getZeroTime() {
                cell.backgroundColor = UIColor(hex: "FFFFFF", alpha: 0)
                return cell
            }
            let totalPointsForCell = activitiesForCell.reduce(0, +) // 合計
            switch totalPointsForCell {
            case 0 :
                cell.backgroundColor = UIColor(hex: "FFFFFF", alpha: 0.46)
            case 1...30:
                cell.backgroundColor = UIColor(hex: "45E1FF", alpha: 0.46)
            case 30...70:
                cell.backgroundColor = UIColor(hex: "3D83BC", alpha: 0.46)
            case 70...100:
                cell.backgroundColor = UIColor(hex: "008DDC", alpha: 0.46)
            default:
                cell.backgroundColor = UIColor(hex: "1D5CAC", alpha: 0.46)
            }
            return cell
        } else if collectionView.tag == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "frienddatacell", for: indexPath)  as! FriendDataCell
            cell.nameLabel.text = friendDataList[indexPath.row].name
            cell.iconView.kf.setImage(with: URL(string: friendDataList[indexPath.row].iconImageURL)!)
            return cell
        } else {
            fatalError("collectionView Tag Invalid")
        }
    }
    //友達を削除する
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 1 {
            //MARK: - activityGrass
        } else if collectionView.tag == 0 {
            //MARK: - friendList
            guard let deleteFriendId = friendDataList[indexPath.row].id else { return }
            let alert = UIAlertController(title: "注意", message: "友達を削除しますか？", preferredStyle: .alert)
            let delete = UIAlertAction(title: "削除", style: .destructive, handler: { [self] (action) -> Void in
                let task = Task {
                    do {
                        try await FirebaseClient.shared.deleteFriendQuery(deleteFriendId: deleteFriendId)
                        friendDataList = try await FirebaseClient.shared.getProfileData(includeMe: false)
                        self.friendcollectionView.reloadData()
                    }
                    catch {
                        let alert = UIAlertController(title: "エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                            self.viewDidLoad()
                        }
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)
                        print("FriendListViewContro collectionview error:",error.localizedDescription)
                    }
                }
                cancellables.insert(.init { task.cancel() })
            })
            let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) -> Void in
            })
            alert.addAction(delete)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        } else {
            fatalError("collectionView Tag Invalid")
        }
        
    }
}

extension FriendListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        pointDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentActivitysTableViewCell", for: indexPath) as! RecentActivitysTableViewCell
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        let dataStr = dateFormatter.string(from: pointDataList[indexPath.row].date)
        cell.pointLabel.text = "+\(pointDataList[indexPath.row].point ?? 0)pt"
        cell.dateLabel.text = dataStr
        cell.activityLabel.text = pointDataList[indexPath.row].activity ?? ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //ヘッダーの肥大化を回避
        return "   "
    }
}

extension FriendListViewController: UIAdaptivePresentationControllerDelegate {
  func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
      myNameLabel.text = UserDefaults.standard.object(forKey: "name")! as? String
      myIconView.kf.setImage(with: URL(string: UserDefaults.standard.object(forKey: "IconImageURL") as! String))
  }
}
