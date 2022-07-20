import UIKit
import Firebase
import SwiftUI
import FirebaseFirestore

class ViewController: UIViewController, UITextFieldDelegate {
    
    var me: User!
    var auth: Auth!
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser
    var friendIdList = [String]()
    
    var friendList = [User]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    @IBOutlet var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: 500, height: 100)
            collectionView.collectionViewLayout = layout
            
            collectionView.register(UINib(nibName: "DashBoardFriendDataCell", bundle: nil), forCellWithReuseIdentifier: "DashBoardFriendDataCell")
        }
    }
    
    
    @IBOutlet var loginLabel: UILabel!
    @IBAction func dataputButton() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "HealthDataViewController")
        self.showDetailViewController(secondVC, sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        auth = Auth.auth()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let task = Task { [weak self] in
            do {
                let frinedIds = try? await FirebaseClient.shared.getfriendIds()
                for try await id in frinedIds {
                    let friend = try? await FirebaseClient.shared.getUserDataFromId(friendId: id)
                    if let friend = friend {
                        self?.friendList.append(friend)
                        //FIXME: 本当はここで呼びたくない
                        self?.collectionView.reloadData()
                    }
                }
            }
            catch {
                //TODO: ERROR Handling
                print("error")
            }
        }
        
    }
    //友達の情報をとってくる
    func getfriendIds(completion: @escaping ([String]) -> Void)  {
        
        guard let userID = user?.uid else { return }
        let db = Firestore.firestore()
        db.collection("UserData").document(userID).collection("friendsList").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if let snapShot = querySnapshot {
                    let documents = snapShot.documents
                    self.friendIdList = documents.compactMap {
                        return $0.data()["friendId"] as! String
                    }
                    print("友達のID\(self.friendIdList)")
                    completion(self.friendIdList)
                }
            }
        }
    }
    
    
    func getUserDataFromIds(friendIdList: [String]){
        let db = Firestore.firestore()
        for friendId in friendIdList {
            db.collection("UserData").document(friendId).getDocument { (snapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    if let snapshot = snapshot {
                        let user = try? snapshot.data(as: User.self)
                        self.friendList.append(user!)
                        //TODO: didSetを呼ぶために仕方なく代入している
                        self.friendList = self.friendList
                        print(self.friendList)
                    }
                }
            }
        }
    }
}



extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friendList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DashBoardFriendDataCell", for: indexPath)  as! DashBoardFriendDataCell
        cell.nameLabel.text = friendList[indexPath.row].name
        return cell
    }
}
