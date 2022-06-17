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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(userID)
        print("ユーザーIDを取得しました")
        shareUrlString = "sanitas-ios-dev://?id=\(userID)"
        
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
    
    @IBAction func addFriend() {
        
        var friendId: String!
        
        if let currentUser = Auth.auth().currentUser {
            let db = Firestore.firestore()
            db.collection("UserData")
                .document(currentUser.uid)
                .collection("friendsList")
                .document("\(Date())") // サブコレクションであるprefecturesがない場合、自動でリストが生成される。
                .setData([
                    "friendId": String(friendId)
                ]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
        }
    }
    
    //    ログアウトする
    @IBAction func logoutButton() {
        let firebaseAuth = Auth.auth()
        do {
            let alert3 = UIAlertController(title: "注意", message: "ログアウトしますか？", preferredStyle: .alert)
            
            let delete = UIAlertAction(title: "ログアウト", style: .destructive, handler: { (action) -> Void in
                Auth.auth().currentUser?.delete()
                print("ログアウトしました")
                
                let alert = UIAlertController(title: "ログアウトしました", message: "ありがとうございました",     preferredStyle: .alert)
                self.performSegue(withIdentifier: "toAccountCreate", sender: nil)
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
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "AccountViewController")
        showDetailViewController(secondVC, sender: self)
    }
    
    //    アカウントを削除する
    @IBAction func deleteAccount() {
        let alert = UIAlertController(title: "注意", message: "アカウントを削除しますか？", preferredStyle: .alert)
        
        let delete = UIAlertAction(title: "削除", style: .destructive, handler: { (action) -> Void in
            Auth.auth().currentUser?.delete()
            print("アカウントを削除しました")
            
            let alert2 = UIAlertController(title: "アカウントを削除しました", message: "ありがとうございました",     preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            alert2.addAction(ok)
            self.present(alert2, animated: true, completion: nil)
            
            self.performSegue(withIdentifier: "toAccountCreate", sender: nil)
        })
        
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) -> Void in
            print("キャンセル")
        })
        
        alert.addAction(delete)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
