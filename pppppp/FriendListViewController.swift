//
//  FriendListViewController.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/05/18.
//

import UIKit
import Firebase
import FirebaseFirestore


class FriendListViewController: UIViewController {
    
    var auth: Auth!
    let user = Auth.auth().currentUser
    var shareUrlString: String?
    var completionHandlers = [() -> Void]()
    var friendIdList = [String]()
    
    var friendList = [User]() {
        didSet {
            self.friendcollectionView.reloadData()
        }
    }
    
    
    
    @IBOutlet var mynameLabel: UILabel!
    @IBAction func dataputButton() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "MeViewController")
        self.showDetailViewController(secondVC, sender: self)
    }
    
    @IBOutlet var friendcollectionView: UICollectionView! {
        didSet {
            friendcollectionView.delegate = self
            friendcollectionView.dataSource = self
            
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: 500, height: 50)
            friendcollectionView.collectionViewLayout = layout
            
            friendcollectionView.register(UINib(nibName: "FriendDataCell", bundle: nil), forCellWithReuseIdentifier: "frienddatacell")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        auth = Auth.auth()
    }

    override func viewDidAppear(_ animated: Bool) {
        //ログインできてるかどうかの判定
        if auth.currentUser != nil {
            auth.currentUser?.reload(completion: { [self] error in
                if error == nil {
                    if self.auth.currentUser?.isEmailVerified == true {
                        print("ログインしています")
                        return
                    } else {
                        //メール認証がまだ
                        if self.auth.currentUser?.isEmailVerified == false {
                            let alert = UIAlertController(title: "確認用メールを送信しているので確認をお願いします。", message: "まだメール認証が完了していません。", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            })
        } else if auth.currentUser == nil{
            print("ログインされてない！ログインしてください")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let secondVC = storyboard.instantiateViewController(identifier: "AccountViewController")
            showDetailViewController(secondVC, sender: self)
        }

//        print(userID)
        guard let userID = user?.uid else { return }
        print("自分のユーザーIDを取得しました")
        shareUrlString = "sanitas-ios-dev://?id=\(userID)"

        getfriendIds { [weak self] friendIdList in
        self?.getUserDataFromIds(friendIdList: friendIdList)
        }

        getname()

    }
    
    //    名前を表示
    func getname() {
        guard let userID = user?.uid else { return }
        let db = Firestore.firestore()
        db.collection("UserData").document(userID).getDocument { (snapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if let snapshot = snapshot {
                    let user = snapshot.data()!["name"]!
                    print(user)
                    self.mynameLabel.text = user as? String
                }
            }
        }
    }
    
    //    友達の情報をとってくる
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
    
    //    リンクのシェアシート出す
    @IBAction func pressedButton() {
        showShareSheet()
    }
    
    func showShareSheet() {
        guard let userID = user?.uid else { return }
        let shareWebsite = URL(string: "sanitas-ios-dev://?id=\(userID)")!
        let activityVC = UIActivityViewController(activityItems: [shareWebsite], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
        print("リンクをシェアします")
    }
    
    //    ログアウトする
    @IBAction func logoutButton() {
        let firebaseAuth = Auth.auth()
        do {
            let alert3 = UIAlertController(title: "注意", message: "ログアウトしますか？", preferredStyle: .alert)
            
            let delete = UIAlertAction(title: "ログアウト", style: .destructive, handler: { (action) -> Void in
                Auth.auth().currentUser?.delete()
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let secondVC = storyboard.instantiateViewController(identifier: "AccountViewController")
                self.showDetailViewController(secondVC, sender: self)
                
                print("ログアウトしました")
                
                let alert = UIAlertController(title: "ログアウトしました", message: "ありがとうございました", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                }
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
                
            })
            
            let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) -> Void in
                print("キャンセル")
            })
            
            alert3.addAction(delete)
            alert3.addAction(cancel)
            
            self.present(alert3, animated: true, completion: nil)
            
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    //    アカウントを削除する
    @IBAction func deleteAccount() {
        let alert = UIAlertController(title: "注意", message: "アカウントを削除しますか？", preferredStyle: .alert)
        
        let delete = UIAlertAction(title: "削除", style: .destructive, handler: { (action) -> Void in
            Auth.auth().currentUser?.delete()
            print("アカウントを削除しました")
            
            let alert2 = UIAlertController(title: "アカウントを削除しました", message: "ありがとうございました", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            alert2.addAction(ok)
            self.present(alert2, animated: true, completion: nil)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let secondVC = storyboard.instantiateViewController(identifier: "AccountViewController")
            self.showDetailViewController(secondVC, sender: self)
        })
        
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) -> Void in
            print("キャンセル")
        })
        
        alert.addAction(delete)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension FriendListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friendList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "frienddatacell", for: indexPath)  as! FriendDataCell
        cell.nameLabel.text = friendList[indexPath.row].name
        cell.idLabel.text = friendList[indexPath.row].id
        
        return cell
    }
    
    
    //セルをタップしたら友達を削除するかのアラート
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let deleteFriendId = friendList[indexPath.row].id else { return }
        
        let db = Firestore.firestore()
        let alert = UIAlertController(title: "注意", message: "友達を削除しますか？", preferredStyle: .alert)
        let delete = UIAlertAction(title: "削除", style: .destructive, handler: { (action) -> Void in
            if let currentUser = Auth.auth().currentUser {
                
                db.collection("UserData").document(currentUser.uid).collection("friendsList").document(deleteFriendId).delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    } else {
                        db.collection("UserData").document(deleteFriendId).collection("friendsList").document(currentUser.uid).delete() { err in
                            if let err = err {
                                print("Error removing document: \(err)")
                            } else {
                                print("自分を友達のリストから削除しました")
                                let alert = UIAlertController(title: "友達の削除", message: "友達を削除しました。", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                        print("友達を削除しました")
                    }
                }
            }
            
            let alert2 = UIAlertController(title: "友達の削除", message: "友達を削除しました", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            alert2.addAction(ok)
            self.present(alert2, animated: true, completion: nil)
        })
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) -> Void in
            print("キャンセル")
        })
        alert.addAction(delete)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
}
