import UIKit
import Firebase
import FirebaseFirestore

class ProfileNameViewController: UIViewController, UITextFieldDelegate {
    
    var profileName: String = ""
    @IBOutlet var nameTextField: UITextField!
    @IBAction func nameButton() {
        
        profileName = nameTextField.text!
        saveProfileName(profileName: profileName)
        self.performSegue(withIdentifier: "toooViewController", sender: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameTextField?.delegate = self
    }
    
    //irebaseに名前を保存
    func saveProfileName(profileName: String) {
        if let currentUser = Auth.auth().currentUser {
            let db = Firestore.firestore()
            db.collection("UserData")
                .document(currentUser.uid)
                .setData([
                    "name": String(profileName)
                ]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("名前をfirestoreに保存しました")
                    }
                }
        }
    }
}
