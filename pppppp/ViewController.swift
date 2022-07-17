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
            layout.itemSize = CGSize(width: 500, height: 300)
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
        
        //ログインできてるかとfirestoreに情報があるかの判定
        if auth.currentUser != nil {
            auth.currentUser?.reload(completion: { [self] error in
                if error == nil {
                    if self.auth.currentUser?.isEmailVerified == true {
                        print("ログインしています")
                        //名前があるかどうかの判定
                        let userID = user?.uid
                        let db = Firestore.firestore()
                        db.collection("UserData").document(userID!).getDocument { [self] (snapshot, err) in
                            if let err = err {
                                print("自分の名前を取得しようとした/エラーは: \(err)")
                            } else {
                                if let snapshot = snapshot {
                                    if snapshot.data()?["name"]! == nil {
                                        print("自分の名前を取得しようとした/firestoreに情報なし")
                                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                        let secondVC = storyboard.instantiateViewController(identifier: "ProfileNameViewController")
                                        showDetailViewController(secondVC, sender: self)
                                        
                                    } else {
                                        print(snapshot.data()!["name"]!)
                                    }
                                }
                                return
                            }
                        };return
                    } else {
                        //メール認証がまだ
                        if self.auth.currentUser?.isEmailVerified == false {
                            let alert = UIAlertController(title: "まだメール認証が完了していません。", message: "確認用メールを送信しているので確認をお願いします。", preferredStyle: .alert)
                            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let secondVC = storyboard.instantiateViewController(identifier: "AccountViewController")
                                self.showDetailViewController(secondVC, sender: self)
                            }
                            alert.addAction(ok)
                            present(alert, animated: true, completion: nil)
                        }
                    }
                }
            })
        } else if auth.currentUser == nil{
            print("ログインされてない")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let secondVC = storyboard.instantiateViewController(identifier: "AccountViewController")
            showDetailViewController(secondVC, sender: self)
        }
        
        getfriendIds { [weak self] friendIdList in
            self?.getUserDataFromIds(friendIdList: friendIdList)
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
//        cell.idLabel.text = friendList[indexPath.row].id
        return cell
    }
}
