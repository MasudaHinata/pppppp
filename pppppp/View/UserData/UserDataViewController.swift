//
//  UserDataViewController.swift
//  pppppp
//
//  Created by hinata on 2022/08/30.
//

import UIKit
import Combine

class UserDataViewController: UIViewController {
    
    //    var friendDataList = [UserData]()
    let layout = UICollectionViewFlowLayout()
    var cancellables = Set<AnyCancellable>()
    var userDataItem: UserData?
    var pointDataList = [PointData]()
    
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
        let task = Task {
            do {
                pointDataList = try await FirebaseClient.shared.getPointData(id: (userDataItem?.id)!)
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
                print("CollectionViewContro ViewDid error:",error.localizedDescription)
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        iconView.kf.setImage(with: URL(string: userDataItem!.iconImageURL))
        nameLabel.text = userDataItem?.name
        pointLabel.text = "\(userDataItem?.point ?? 0)pt"
    }
}
extension UserDataViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 112
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
        case 1...50:
            cell.backgroundColor = UIColor(hex: "45E1FF", alpha: 0.46)
        case 50...100:
            cell.backgroundColor = UIColor(hex: "3D83BC", alpha: 0.46)
        case 100...150:
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
        cell.pointLabel.text = String(pointDataList[indexPath.row].point ?? 0)
        cell.dateLabel.text = pointDataList[indexPath.row].id
        return cell
    }
}
