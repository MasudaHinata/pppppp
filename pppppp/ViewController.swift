import Combine
import UIKit
import SwiftUI
import Kingfisher

class ViewController: UIViewController, UITextFieldDelegate, FirebaseEmailVarify ,FirebasePutPoint {
    var cancellables = Set<AnyCancellable>()
    var friendIdList = [String]()
    var refreshControl = UIRefreshControl()
    var friendDataList = [FriendListItem]()
    let layout = UICollectionViewFlowLayout()
    let UD = UserDefaults.standard
    let calendar = Calendar.current
    @IBOutlet var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            
            layout.minimumLineSpacing = 22
            collectionView.collectionViewLayout = layout
            
            collectionView.register(UINib(nibName: "DashBoardFriendDataCell", bundle: nil), forCellWithReuseIdentifier: "DashBoardFriendDataCell")
        }
    }
    @IBAction func dataputButton() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "HealthDataViewController")
        self.showDetailViewController(secondVC, sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FirebaseClient.shared.emailVerifyDelegate = self
        FirebaseClient.shared.putPoint = self
        NotificationManager.setCalendarNotification(title: "自己評価をしてポイントを獲得しましょう", body: "19時になりました")
        
        collectionView.refreshControl = refreshControl
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(ViewController.refresh(sender:)), for: .valueChanged)
        
        Scorering.shared.getPermissionHealthKit()
        layout.estimatedItemSize = CGSize(width: self.view.frame.width * 0.9, height: 130)
        
        friendDataList.removeAll()
        let tassk = Task { [weak self] in
            do {
                try await FirebaseClient.shared.userAuthCheck()
                try await FirebaseClient.shared.emailVerifyRequiredCheck()
                
                //                try await Scorering.shared.createStepPoint()
                friendDataList = try await FirebaseClient.shared.getFriendProfileData()
                print("friendDataList")
                print(friendDataList)
                self!.collectionView.reloadData()
            }
            catch {
                let alert = UIAlertController(title: "エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default)
                alert.addAction(action)
                self!.present(alert, animated: true)
                print("ViewContro ViewDid error:",error.localizedDescription)
            }
        }
        cancellables.insert(.init { tassk.cancel() })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var judge = Bool()
        let now = calendar.component(.hour, from: Date())
        print(now)
        if now >= 19 {
            judge = true
        }
        else {
            judge = false
        }
        if judge == true {
            judge = false
            print("19時以降だから自己評価よぶ")
            var judgge = Bool()
            if UD.object(forKey: "sss") != nil {
                let past_day = UD.object(forKey: "sss") as! Date
                let noww = calendar.component(.day, from: Date())
                let past = calendar.component(.day, from: past_day)
                print(UD.object(forKey: "sss")!)
                if noww != past {
                    judgge = true
                } else {
                    judgge = false
                }
            } else {
                judgge = true
                UD.set(Date(), forKey: "sss")
                print(UD.object(forKey: "sss")!)
            }
            if judgge == true {
                judgge = false
                print("日付変わったから自己評価する")
                UD.set(Date(), forKey: "sss")
                print(UD.object(forKey: "sss")!)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let secondVC = storyboard.instantiateViewController(identifier: "SelfAssessmentViewController")
                self.showDetailViewController(secondVC, sender: self)
            } else {
                print("今日はもう自己評価した")
            }
        }
        else {
            print("まだ19時前")
        }
    }
    @objc func refresh(sender: UIRefreshControl) {
        let task = Task { [weak self] in
            do {
                guard let self = self else { return }
                friendDataList = try await FirebaseClient.shared.getFriendProfileData()
                self.collectionView.reloadData()
            }
            catch {
                let alert = UIAlertController(title: "エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default)
                alert.addAction(action)
                self!.present(alert, animated: true)
                print("ViewContro refresh error",error.localizedDescription)
            }
        }
        cancellables.insert(.init { task.cancel() })
        refreshControl.endRefreshing()
    }
    func emailVerifyRequiredAlert() {
        let alert = UIAlertController(title: "仮登録が完了していません", message: "メールを確認してください", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let secondVC = storyboard.instantiateViewController(identifier: "AccountViewController")
            self.showDetailViewController(secondVC, sender: self)
        }
        alert.addAction(ok)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    func putPointForFirestore(point: Int) {
        let alert = UIAlertController(title: "ポイントを獲得しました", message: "あなたのポイントは\(point)pt", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friendDataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DashBoardFriendDataCell", for: indexPath)  as! DashBoardFriendDataCell
        
        cell.nameLabel.text = friendDataList[indexPath.row].name
        cell.dataLabel.text = String(friendDataList[indexPath.row].point ?? 0)
        cell.iconView.kf.setImage(with: URL(string: friendDataList[indexPath.row].IconImageURL)!)
        return cell
    }
}
