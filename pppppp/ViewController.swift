import Combine
import UIKit
import SwiftUI
import Kingfisher

class ViewController: UIViewController, UITextFieldDelegate {
    var cancellables = Set<AnyCancellable>()
    //    let refreshControl = UIRefreshControl()
    var me: User!
    var friendIdList = [String]()
    var friendNameList = [User]()
    var friendPointList = [UserHealth]()
    var friendIconList = [UserIcon]()
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
    @IBAction func reloadButton() {
        friendNameList.removeAll()
        friendPointList.removeAll()
        friendIconList.removeAll()
        let task = Task { [weak self] in
            do {
                let friendIds = try? await FirebaseClient.shared.getfriendIds()
                guard var friendIds = friendIds else { return }
//                friendIds += [String(user!.uid)]
                for id in friendIds {
                    let friend = try? await FirebaseClient.shared.getUserDataFromId(friendId: id)
                    if let friend = friend {
                        self?.friendNameList.append(friend)
                    }
                    let friends = try? await FirebaseClient.shared.getHealthDataFromId(friendsId: id)
                    if let friends = friends {
                        self?.friendPointList.append(friends)
                    }
                    let friendss = try? await FirebaseClient.shared.getIconDataFromId(friendIds: id)
                    if let friendss = friendss {
                        self?.friendIconList.append(friendss)
                    }
                    self!.collectionView.reloadData()
                }
            }
            catch {
                //TODO: ERROR Handling
                print("error")
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationManager.setCalendarNotification(title: "自己評価をしてポイントを獲得しましょう", body: "19時になりました")
        let task = Task {
            do {
                try await FirebaseClient.shared.validate()
            } catch {
                print(error.localizedDescription)
            }
        }
        
//        let dateComponents = DateComponents(calendar: Calendar.current, timeZone: TimeZone.current, hour: 19, minute: 00)
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
//        let content = UNMutableNotificationContent()
//        //TODO: 文ちゃんと考える
//        content.title = "自己評価をしてポイントを獲得しましょう"
//        content.body = "19時になりました"
//        content.sound = UNNotificationSound.default
//        var request = UNNotificationRequest.init(identifier: "自己評価をしてポイントを獲得しましょう", content: content, trigger: trigger)
//        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        //        collectionView.refreshControl = refreshControl
        //        refreshControl.addTarget(self, action: #selector(ViewController.refresh(sender:)), for: .valueChanged)
        
        Scorering.shared.getPermissionHealthKit()
        layout.estimatedItemSize = CGSize(width: self.view.frame.width * 0.9, height: 130)
        
        friendNameList.removeAll()
        friendPointList.removeAll()
        friendIconList.removeAll()
        let tassk = Task { [weak self] in
            do {
                try await Scorering.shared.createStepPoint()

                let friendIds = try? await FirebaseClient.shared.getfriendIds()
                guard var friendIds = friendIds else { return }
//                friendIds += [String(user!.uid)]
                for id in friendIds {
                    let friend = try? await FirebaseClient.shared.getUserDataFromId(friendId: id)
                    if let friend = friend {
                        self?.friendNameList.append(friend)
                    }
                    let friends = try? await FirebaseClient.shared.getHealthDataFromId(friendsId: id)
                    if let friends = friends {
                        self?.friendPointList.append(friends)
                    }
                    let friendss = try? await FirebaseClient.shared.getIconDataFromId(friendIds: id)
                    if let friendss = friendss {
                        self?.friendIconList.append(friendss)
                    }
                    self!.collectionView.reloadData()
                }
            }
            catch {
                //TODO: ERROR Handling
                print("error")
            }
        }
        cancellables.insert(.init { tassk.cancel() })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var judge = Bool()
        let now = calendar.component(.hour, from: Date())
        print(now)
        //        UserDefaults.standard.removeObject(forKey: "sss")
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
//    @objc func refresh(sender: UIRefreshControl) {
//        //ここに通信処理などデータフェッチの処理を書く
//        //データフェッチが終わったらUIRefreshControl.endRefreshing()を呼ぶ必要がある
//        friendNameList.removeAll()
//        friendPointList.removeAll()
//        friendIconList.removeAll()
//        let task = Task { [weak self] in
//            do {
//                let friendIds = try? await FirebaseClient.shared.getfriendIds()
//                guard var friendIds = friendIds else { return }
//                friendIds += [String(user!.uid)]
//                for id in friendIds {
//                    let friend = try? await FirebaseClient.shared.getUserDataFromId(friendId: id)
//                    if let friend = friend {
//                        self?.friendNameList.append(friend)
//                    }
//                    let friends = try? await FirebaseClient.shared.getHealthDataFromId(friendsId: id)
//                    if let friends = friends {
//                        self?.friendPointList.append(friends)
//                    }
//                    let friendss = try? await FirebaseClient.shared.getIconDataFromId(friendIds: id)
//                    if let friendss = friendss {
//                        self?.friendIconList.append(friendss)
//                    }
//                    self!.collectionView.reloadData()
//                }
//            }
//            catch {
//                //TODO: ERROR Handling
//                print("error")
//            }
//        }
//        cancellables.insert(.init { task.cancel() })
        //UIRefreshControl.endRefreshing()
//    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friendNameList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DashBoardFriendDataCell", for: indexPath)  as! DashBoardFriendDataCell
        
        cell.nameLabel.text = friendNameList[indexPath.row].name
        cell.dataLabel.text = String(friendPointList[indexPath.row].point)
        cell.iconView.kf.setImage(with: URL(string: friendIconList[indexPath.row].imageURL)!)
        return cell
    }
}
