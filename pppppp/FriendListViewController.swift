//
//  FriendListViewController.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/05/18.
//

import UIKit
import Firebase


class FriendListViewController: UIViewController {
    
    var auth: Auth!
    let user = Auth.auth().currentUser
    var shareUrlString: String?
    let userID = Auth.auth().currentUser!.uid
    var friendId: String = "x8TAcesm4Yarre6ZTuOJX5Z81Ty2"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(userID)
        print("自分のユーザーIDを取得しました")
        shareUrlString = "sanitas-ios-dev://?id=\(userID)"
        
    }
    //    友達を削除する
    @IBAction func deleteFriends() {
        
        let alert = UIAlertController(title: "注意", message: "友達を削除しますか？", preferredStyle: .alert)
        
        let delete = UIAlertAction(title: "削除", style: .destructive, handler: { (action) -> Void in
            
            if let currentUser = Auth.auth().currentUser {
                let db = Firestore.firestore()
                db.collection("UserData")
                    .document(currentUser.uid)
                    .collection("friendsList")
                    .document(self.friendId)
                    .delete() { err in
                        if let err = err {
                            print("Error removing document: \(err)")
                        } else {
                            self.mydelete()
                            print("友達を削除しました")
                        }
                    }
            }
            
            print("友達を削除したのよ")
            
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
    
    func mydelete () {
        
        if let currentUser = Auth.auth().currentUser {
            let db = Firestore.firestore()
            db.collection("UserData")
                .document(friendId)
                .collection("friendsList")
                .document(userID)
                .delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    } else {
                        print("自分を友達のリストから削除しました")
                        let alert = UIAlertController(title: "友達の削除", message: "友達を削除しました。", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
        }
        
    }
                
                
    
    //    リンクのシェアシート出す
    @IBAction func pressedButton() {
        
        showShareSheet()
        
    }
    
    func showShareSheet() {
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
