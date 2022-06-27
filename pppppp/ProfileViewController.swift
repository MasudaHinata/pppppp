//
//  ProfileViewController.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/06/15.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(userID)
        print(friendId)
        print("ああああああああ")
        getfriendsname()
        
    }
    
    var friendId: String!
    let userID = Auth.auth().currentUser!.uid
    
    @IBOutlet var friendLabel: UILabel!
    
    @IBAction func backButton(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "ViewController")
        self.showDetailViewController(secondVC, sender: self)
    }
    
    //    友達の名前を取得する
    func getfriendsname() {
        
        let db = Firestore.firestore()
        let docRef = db.collection("UserData")
            .document(friendId)
            .collection("profileData")
            .document("nameData")
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                print("友達の名前は\(document.data()!["name"]!)")
                self.friendLabel.text = "\(document.data()!["name"]!)"
            } else {
                print("存在してない")
            }
        }
    }
    
    
    //    友達を追加する
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
                        addfriend2()
                        print("fireStoreに保存して友達を追加したよ")
                    }
                }
        }
    }
    func addfriend2() {
        
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
                    print("友達のフレンドリストに自分を追加したよ")
                    let alert = UIAlertController(title: "友達追加", message: "友達になりました", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
    }
    
    
}
