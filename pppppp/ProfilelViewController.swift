//
//  GoalViewController.swift
//  pppppp
//
//  Created by 増田ひなた on 2021/06/02.
//

//
//if let currentUser = Auth.auth().currentUser {
//    let db = Firestore.firestore()
//    db.collection("UserData")
//        .document(currentUser.uid)
//        .collection("friendsList")
//                .document("\(Date())") // サブコレクションであるprefecturesがない場合、自動でリストが生成される。
//                .setData([
//                    "friendId": String(friendId)
//    ]) { err in
//        if let err = err {
//            print("Error writing document: \(err)")
//        } else {
//            print("Document successfully written!")
//        }
//    }
//}

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    @IBOutlet var goalTextField: UITextField!
    @IBOutlet var userIDTextField: UITextField!
    @IBOutlet var goButton: UIButton!
    
    
    let saveData: UserDefaults = Foundation.UserDefaults.standard

   override func viewDidLoad() {
        super.viewDidLoad()
       design()
    }
    
    func design() {
        goalTextField.layer.cornerRadius = 24
        goButton.layer.cornerRadius = 24
        goalTextField.clipsToBounds = true
        goButton.clipsToBounds = true
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        saveData.set(goalTextField.text, forKey: "key")
    }

    @IBAction func okButtonPressed() {
        performSegue(withIdentifier: "toTimeline", sender: nil)
    }
    
    @IBAction func UserID() {
        
        var userId: String!
        userId = userIDTextField.text
        
        if let currentUser = Auth.auth().currentUser {
            let db = Firestore.firestore()
            db.collection("UserData")
                .document(currentUser.uid)
                .collection("userData")
                        .document("\(Date())") // サブコレクションであるprefecturesがない場合、自動でリストが生成される。
                        .setData([
                            "userId": String(userId)
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
