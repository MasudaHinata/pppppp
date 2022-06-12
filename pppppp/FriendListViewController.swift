//
//  FriendListViewController.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/05/18.
//

import UIKit
import Firebase
import FirebaseDynamicLinks


class FriendListViewController: UIViewController {

    @IBOutlet var textField: UITextField!
    @IBOutlet var label: UILabel!
    @IBAction func checkButton() {
        
    }
    
    @IBAction func rejectButton() {
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
