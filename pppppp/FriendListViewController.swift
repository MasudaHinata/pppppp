//
//  FriendListViewController.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/05/18.
//

import UIKit
import Firebase


class FriendListViewController: UIViewController {
    
    @IBOutlet var textField: UITextField!
    @IBAction func pressedButton() {
        
        showShareSheet()
        
    }
    
    var shareUrlString: String?
    let userID = Auth.auth().currentUser!.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(userID)
        print("ユーザーIDを取得しました")
        shareUrlString = "sanitas-ios-dev://?id=\(userID)"
        
    }
    
    func showShareSheet() {
        let shareWebsite = URL(string: "sanitas-ios-dev://?id=\(userID)")!
        let activityVC = UIActivityViewController(activityItems: [shareWebsite], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
        print("リンクをシェアします")
    }
    
    @IBAction func addFriend() {
        
        var friendId: String!
        friendId = textField.text
        
        
        
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
}