import UIKit
import Firebase
import FirebaseFirestore

class ProfileViewController: UIViewController {
    
    var friendId: String!
    let userID = Auth.auth().currentUser!.uid
    let db = Firestore.firestore()
    
    @IBOutlet var friendLabel: UILabel!
    @IBOutlet var backLabel: UILabel!
    @IBOutlet var addFriendButton: UIButton!
    
    @IBAction func backButton(){
        self.performSegue(withIdentifier: "toViewController", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getfriendsname()
        
        addFriendButton.layer.borderWidth = 4.0
        addFriendButton.layer.borderColor = UIColor.white.cgColor
        addFriendButton.layer.cornerRadius = 12.0
        backLabel.layer.cornerRadius = 32.0
        backLabel.clipsToBounds = true
    }
    //友達の名前を取得する
    func getfriendsname() {
        let docRef = db.collection("UserData").document(friendId)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                print("友達の名前は\(document.data()!["name"]!)")
                self.friendLabel.text = "\(document.data()!["name"]!)"
            } else {
                print("error存在してない")
            }
        }
    }
    //    友達を追加する
    @IBAction func addFriend() {
        db.collection("UserData").document(userID).collection("friendsList").document(friendId).setData(["friendId": friendId]) { [self] err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                db.collection("UserData").document(friendId).collection("friendsList").document(userID).setData(["friendId": userID]) { [self] err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        let alertController = UIAlertController(title: "友達追加", message: "友達を追加しました", preferredStyle: UIAlertController.Style.alert)
                        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{(action: UIAlertAction!) in
                            self.performSegue(withIdentifier: "toViewController", sender: nil)
                        })
                        alertController.addAction(okAction)
                        present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}
