//
//  ProfileViewController.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/06/15.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    //    x8TAcesm4Yarre6ZTuOJX5Z81Ty2
    
    @IBAction func backButton(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "ViewController")
        self.showDetailViewController(secondVC, sender: self)
    }
    
    var friendId: String = "x8TAcesm4Yarre6ZTuOJX5Z81Ty2"
    
    @IBAction func addFriend() {
        
//        let friendId: String = "x8TAcesm4Yarre6ZTuOJX5Z81Ty2"
        
        if let currentUser = Auth.auth().currentUser {
            let db = Firestore.firestore()
            db.collection("UserData")
                .document(currentUser.uid)
                .collection("friendsList")
                .document("\(Date())") // サブコレクションであるprefecturesがない場合、自動でリストが生成される。
                .setData([
                    "friendId": String(friendId)
                ]) { [self] err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("fireStoreに保存して友達を追加したよ")
                        let alert = UIAlertController(title: "友達を追加しました", message: "\(self.friendId)を友達追加しました", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                        }
                        alert.addAction(ok)
                    }
                }
        }
    }
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
