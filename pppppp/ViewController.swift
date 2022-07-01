import UIKit
import Firebase
import SwiftUI
import FirebaseFirestore

class ViewController: UIViewController, UITextFieldDelegate {
    
    var me: User!
    var auth: Auth!
    let db = Firestore.firestore()
    
    @IBOutlet var loginLabel: UILabel!
    @IBAction func friendsButton() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "FriendListViewController")
        self.showDetailViewController(secondVC, sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        auth = Auth.auth()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //ログインできてるかどうかの判定
        if auth.currentUser != nil {
            auth.currentUser?.reload(completion: { [self] error in
                if error == nil {
                    if self.auth.currentUser?.isEmailVerified == true {
                        loginLabel.text = "ログイン中"
                        print("ログインしています")
                        return
                    } else {
                        //メール認証がまだ
                        if self.auth.currentUser?.isEmailVerified == false {
                            let alert = UIAlertController(title: "確認用メールを送信しているので確認をお願いします。", message: "まだメール認証が完了していません。", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            })
        } else if auth.currentUser == nil{
            print("ログインされてない！ログインしてください")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let secondVC = storyboard.instantiateViewController(identifier: "AccountViewController")
            showDetailViewController(secondVC, sender: self)
        }
    }
}

