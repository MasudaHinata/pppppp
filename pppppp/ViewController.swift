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
        layout.estimatedItemSize = CGSize(width: self.view.frame.width * 0.9, height: 130)
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
                let sanitasPoint = Scorering.shared.sanitasPoint
                try await Scorering.shared.firebasePutData(point: sanitasPoint)
                
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
