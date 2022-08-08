import UIKit
import SwiftUI

class ViewController: UIViewController, UITextFieldDelegate {
    
    var me: User!
    var friendIdList = [String]()
    var friendList = [User]()
    var friendsList = [UserHealth]()
    var friendLists = [UserIcon]()
    @IBOutlet var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: 349, height: 130)
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        friendList.removeAll()
        friendsList.removeAll()
        let task = Task { [weak self] in
            do {
                let friendIds = try? await FirebaseClient.shared.getfriendIds()
                guard let friendIds = friendIds else { return }
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

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friendList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DashBoardFriendDataCell", for: indexPath)  as! DashBoardFriendDataCell
        cell.nameLabel.text = friendList[indexPath.row].name
//        cell.dataLabel.text = friendsList[indexPath.row].point
        
        let imageUrl: URL = URL(string: friendLists[indexPath.row].imageURL as! String)!
        let imageData: Data = try! Data(contentsOf: imageUrl)
        cell.iconView.image = UIImage(data: imageData)!
        
        cell.layer.cornerRadius = 27
        return cell
    }
}
