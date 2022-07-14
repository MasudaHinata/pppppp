//
//  ProfileViewController.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/06/15.
//

import UIKit
import Firebase
import FirebaseFirestore

class ProfileViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(userID)
        print(friendId)
        getfriendsname()
    }
    
    
    var friendId: String!
    let userID = Auth.auth().currentUser!.uid
    
    
    @IBOutlet var friendLabel: UILabel!
    
    @IBAction func backButton(){
    }
    
    //    友達の名前を取得する
    func getfriendsname() {
        
        let db = Firestore.firestore()
        let docRef = db.collection("UserData")
            .document(friendId)
        
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
                .setData([
                    
                    "friendId": friendId
                    
                ]) { [self] err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        
                        let db = Firestore.firestore()
                        db.collection("UserData").document(friendId).collection("friendsList").document(userID)
                            .setData([
                                "friendId": userID
                                
                            ]) { [self] err in
                                if let err = err {
                                    print("Error writing document: \(err)")
                                } else {
                                    let alertController = UIAlertController(title: "友達追加", message: "友達を追加しました", preferredStyle: UIAlertController.Style.alert)
                                    let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{(action: UIAlertAction!) in
                                        
                                        
                                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                        let secondVC = storyboard.instantiateViewController(identifier: "ViewController")
                                        self.showDetailViewController(secondVC, sender: self)
                                    }
                                    )
                                    alertController.addAction(okAction)
                                    present(alertController, animated: true, completion: nil)
                                    
                                    print("友達になった")
                                }
                            }
                    }
                }
        }
    }
}
