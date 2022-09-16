import UIKit
import Combine

class UserDataViewController: UIViewController {
    
    var cancellables = Set<AnyCancellable>()
    var userDataItem: UserData?
    var pointDataList = [PointData]()
    var ActivityIndicator: UIActivityIndicatorView!
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
        
        ActivityIndicator = UIActivityIndicatorView()
        ActivityIndicator.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        ActivityIndicator.center = self.view.center
        ActivityIndicator.style = .large
        ActivityIndicator.color = .white
        ActivityIndicator.hidesWhenStopped = true
        self.view.addSubview(ActivityIndicator)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ActivityIndicator.startAnimating()
        iconView.kf.setImage(with: URL(string: userDataItem!.iconImageURL))
        nameLabel.text = userDataItem?.name
        pointLabel.text = "\(userDataItem?.point ?? 0)pt"
        let task = Task {
            do {
                pointDataList = try await FirebaseClient.shared.getPointData(id: (userDataItem?.id)!)
                pointDataList.reverse()
                self.collectionView.reloadData()
                self.tableView.reloadData()
                ActivityIndicator.stopAnimating()
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
extension UserDataViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 112
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SummaryCollectionViewCell", for: indexPath)  as! SummaryCollectionViewCell
        
        let weekday = Int(indexPath.row / 16) // 1行目は0
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
    }
}
extension Date {
    func getZeroTime() -> Date {
        Calendar.current.startOfDay(for: self)
    }
}

extension UserDataViewController: UITableViewDelegate, UITableViewDataSource {
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
        return "  "
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 4
    }
}
