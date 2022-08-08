import UIKit
import Firebase
import FirebaseFirestore

class ProfileNameViewController: UIViewController, UITextFieldDelegate {
    
//    let db = Firestore.firestore()
//    var userID = Auth.auth().currentUser?.uid
//    @IBOutlet var nameTextField: UITextField!
//    var profileName: String = ""
//    @IBAction func nameButton() {
//        profileName = nameTextField.text!
//        saveProfileName(profileName: profileName)
//    }
//    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.nameTextField?.delegate = self
    }
//    //firebaseに名前を保存
//    func saveProfileName(profileName: String) {
//        if profileName != "" {
//            db.collection("UserData").document(userID!).setData(["name": String(profileName)]) { err in
//                if let err = err {
//                    print("Error writing document: \(err)")
//                } else {
//                    print("名前をfirestoreに保存しました")
//                    
//                    let db = FirebaseClient.shared.db
//                    let user = FirebaseClient.shared.user
//                    let docRef = db.collection("UserData").document(self.userID!).collection("IconData").document("Icon")
//                    docRef.getDocument { (document, error) in
//                        if let document = document, document.exists {
//                            let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
//                            print("Document data: \(dataDescription)")
//                            self.performSegue(withIdentifier: "gooooViewController", sender: nil)
//                        } else {
//                            print("Document does not exist")
//                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                            let secondVC = storyboard.instantiateViewController(identifier: "ProfileImageViewController")
//                            self.showDetailViewController(secondVC, sender: self)
//                        }
//                    }
//                }
//            }
//        } else {
//            let alert = UIAlertController(title: "エラー", message: "名前を入力してください", preferredStyle: .alert)
//            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
//                self.dismiss(animated: true, completion: nil)
//            }
//            alert.addAction(ok)
//            present(alert, animated: true, completion: nil)
//        }
//    }
}
