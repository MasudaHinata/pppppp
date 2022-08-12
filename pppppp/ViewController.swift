import UIKit
import SwiftUI
import Kingfisher

class ViewController: UIViewController, UITextFieldDelegate {
    
    var me: User!
    var friendIdList = [String]()
    var friendList = [User]()
    var friendsList = [UserHealth]()
    var friendLists = [UserIcon]()
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
        Scorering.shared.getPermissionHealthKit()
        layout.estimatedItemSize = CGSize(width: self.view.frame.width * 0.9, height: 130)
        
        let now_day = Date(timeIntervalSinceNow: 60 * 9)
        var judge = Bool()
        let now = calendar.component(.hour, from: now_day)
        
        if now >= 19 {
            judge = true
        }
        else {
            judge = false
        }
        if judge == true {
            judge = false
            print("19時以降だから自己評価よぶ")
            
            let nowDay = Date(timeIntervalSinceNow: 60 * 60 * 9)
            var judgge = Bool()
            if UD.object(forKey: "sss") != nil {
                let past_day = UD.object(forKey: "sss") as! Date
                let noww = calendar.component(.day, from: nowDay)
                let past = calendar.component(.day, from: past_day)
                print(UD.object(forKey: "sss")!)
                if noww != past {
                    judgge = true
                } else {
                    judgge = false
                }
            } else {
                judgge = true
                UD.set(nowDay, forKey: "sss")
                print(UD.object(forKey: "sss")!)
            }
            if judgge == true {
                judgge = false
                print("日付変わったから自己評価する")
                UD.set(nowDay, forKey: "sss")
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
    
    let user = FirebaseClient.shared.user
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        friendList.removeAll()
        friendsList.removeAll()
        friendLists.removeAll()
        let task = Task { [weak self] in
            do {
                try await Scorering.shared.createStepPoint()

                let friendIds = try? await FirebaseClient.shared.getfriendIds()
                guard var friendIds = friendIds else { return }
                friendIds += [String(user!.uid)]
                for id in friendIds {
                    let friend = try? await FirebaseClient.shared.getUserDataFromId(friendId: id)
                    if let friend = friend {
                        self?.friendList.append(friend)
                    }
                    let friends = try? await FirebaseClient.shared.getHealthDataFromId(friendsId: id)
                    if let friends = friends {
                        self?.friendsList.append(friends)
                    }
                    let friendss = try? await FirebaseClient.shared.getIconDataFromId(friendIds: id)
                    if let friendss = friendss {
                        self?.friendLists.append(friendss)
                    }
                    self!.collectionView.reloadData()
                }
            }
            catch {
                //TODO: ERROR Handling
                print("error")
            }
        }
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friendList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DashBoardFriendDataCell", for: indexPath)  as! DashBoardFriendDataCell
        cell.layer.cornerRadius = 27
        cell.iconView.layer.cornerRadius = 30
        cell.iconView.clipsToBounds = true
        
        cell.nameLabel.text = friendList[indexPath.row].name
        cell.dataLabel.text = String(friendsList[indexPath.row].point)
        cell.iconView.kf.setImage(with: URL(string: friendLists[indexPath.row].imageURL)!)
        return cell
    }
}
