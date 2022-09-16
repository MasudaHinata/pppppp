import UIKit
import Combine

class UserDataViewController: UIViewController {
    
    var cancellables = Set<AnyCancellable>()
    var userDataItem: UserData?
    var pointDataList = [PointData]()
    var activityIndicator: UIActivityIndicatorView!
    let layout = UICollectionViewFlowLayout()
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var pointLabel: UILabel!
    @IBOutlet var iconView: UIImageView! {
        didSet {
            iconView.layer.cornerRadius = 24
            iconView.layer.cornerCurve = .continuous
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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        activityIndicator.center = self.view.center
        activityIndicator.style = .large
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        activityIndicator.startAnimating()
        iconView.kf.setImage(with: URL(string: userDataItem!.iconImageURL))
        nameLabel.text = userDataItem?.name
        pointLabel.text = "\(userDataItem?.point ?? 0)pt"
        let task = Task {
            do {
                pointDataList = try await FirebaseClient.shared.getPointData(id: (userDataItem?.id)!)
                pointDataList.reverse()
                self.collectionView.reloadData()
                self.tableView.reloadData()
                activityIndicator.stopAnimating()
            }
            catch {
                print("CollectionViewContro ViewDid error:",error.localizedDescription)
                if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                    let alert = UIAlertController(title: "エラー", message: "インターネット接続を確認してください", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                        self.viewDidLoad()
                    }
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
}

//MARK: - extension
extension Date {
    func getZeroTime() -> Date {
        Calendar.current.startOfDay(for: self)
    }
}
