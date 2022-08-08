import UIKit
import Firebase
import FirebaseFirestore

class ProfileNameViewController: UIViewController, UITextFieldDelegate {
    
    var profileName: String = ""
    let db = Firestore.firestore()
    var userID = Auth.auth().currentUser?.uid
    @IBOutlet var nameTextField: UITextField!
    @IBAction func nameButton() {
        profileName = nameTextField.text!
        saveProfileName(profileName: profileName)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameTextField?.delegate = self
    }
    //irebaseに名前を保存
    func saveProfileName(profileName: String) {
        if profileName != "" {
            db.collection("UserData").document(userID!).setData(["name": String(profileName)]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("名前をfirestoreに保存しました")
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let secondVC = storyboard.instantiateViewController(identifier: "ProfileImageViewController")
                    self.showDetailViewController(secondVC, sender: self)
                }
            }
        } else {
            let alert = UIAlertController(title: "エラー", message: "名前を入力してください", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
}
