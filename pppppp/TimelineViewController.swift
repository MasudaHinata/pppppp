import UIKit
import Firebase // 追加

class TimelineViewController: UIViewController {

    var me: AppUser! // 追加
    let db = Firestore.firestore()
    
    
    // Add a new document with a generated ID
       var ref: DocumentReference? = nil
       ref = db.collection("users").addDocument(data: [
           "first": "Ada",
           "last": "Lovelace",
           "born": 1815
       ]) { err in
           if let err = err {
               print("Error adding document: \(err)")
           } else {
               print("Document added with ID: \(ref!.documentID)")
           }
       }
    // Add a second document with a generated ID.
    ref = db.collection("users").addDocument(data: [
        "first": "Alan",
        "middle": "Mathison",
        "last": "Turing",
        "born": 1912
    ]) { err in
        if let err = err {
            print("Error adding document: \(err)")
        } else {
            print("Document added with ID: \(ref!.documentID)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
