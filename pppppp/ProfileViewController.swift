//
//  ProfileViewController.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/06/15.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    @IBAction func backButton(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "ViewController")
        self.showDetailViewController(secondVC, sender: self)
    }
    
    var friendId: String!
    let userID = Auth.auth().currentUser!.uid
    
    @IBAction func addFriend() {
        
        if let currentUser = Auth.auth().currentUser {
            let db = Firestore.firestore()
            db.collection("UserData")
                .document(currentUser.uid)
                .collection("friendsList")
                .document(friendId)
                .setData([:
                ]) { [self] err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        let alert = UIAlertController(title: "友達追加", message: "友達になりました", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        print("fireStoreに保存して友達を追加したよ")
                    }
                }
        }
        
    
        if Auth.auth().currentUser != nil {
            let db = Firestore.firestore()
            db.collection("UserData")
                .document(friendId)
                .collection("friendsList")
                .document(userID) // サブコレクションであるprefecturesがない場合、自動でリストが生成される。
                .setData([:
                ]) { [self] err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("友達のfireStoreに保存して自分を追加したよ")
                    }
                }
        }
    }
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(userID)
        print("自分のユーザーIDを取得しました")
    }
}
