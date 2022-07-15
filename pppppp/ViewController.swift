import UIKit
import Firebase
import SwiftUI
import FirebaseFirestore

class ViewController: UIViewController, UITextFieldDelegate {
    
    var me: User!
    var auth: Auth!
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser
    
    @IBOutlet var loginLabel: UILabel!
    @IBAction func dataputButton() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "HealthDataViewController")
        self.showDetailViewController(secondVC, sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        auth = Auth.auth()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //ログインできてるかとfirestoreに情報があるかの判定
        if auth.currentUser != nil {
            auth.currentUser?.reload(completion: { [self] error in
                if error == nil {
                    if self.auth.currentUser?.isEmailVerified == true {
                        print("ログインしています")
                        //名前があるかどうかの判定
                        let userID = user?.uid
                        let db = Firestore.firestore()
                        db.collection("UserData").document(userID!).getDocument { [self] (snapshot, err) in
                            if let err = err {
                                print("自分の名前を取得しようとした/エラーは: \(err)")
                            } else {
                                if let snapshot = snapshot {
                                    if snapshot.data()?["name"]! == nil {
                                        print("自分の名前を取得しようとした/firestoreに情報なし")
                                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                        let secondVC = storyboard.instantiateViewController(identifier: "ProfileNameViewController")
                                        showDetailViewController(secondVC, sender: self)
                                        
                                    } else {
                                        print(snapshot.data()!["name"]!)
                                    }
                                }
                                return
                            }
                        };return
                    } else {
                        //メール認証がまだ
                        if self.auth.currentUser?.isEmailVerified == false {
                            let alert = UIAlertController(title: "まだメール認証が完了していません。", message: "確認用メールを送信しているので確認をお願いします。", preferredStyle: .alert)
                            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let secondVC = storyboard.instantiateViewController(identifier: "AccountViewController")
                                self.showDetailViewController(secondVC, sender: self)
                            }
                            alert.addAction(ok)
                            present(alert, animated: true, completion: nil)
                        }
                    }
                }
            })
        } else if auth.currentUser == nil{
            print("ログインされてない")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let secondVC = storyboard.instantiateViewController(identifier: "AccountViewController")
            showDetailViewController(secondVC, sender: self)
        }
    }
}

