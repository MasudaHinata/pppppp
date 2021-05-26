//import UIKit
import Firebase // Firebaseをインポート

class AccountViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    var auth: Auth

    override func viewDidLoad() {
        super.viewDidLoad()
        auth = Auth.auth()
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)
           if auth.currentUser != nil {
               // もし既にユーザーにログインができていれば、タイムラインの画面に遷移する。
               // このときに、ユーザーの情報を次の画面の変数に値渡ししておく。(直接取得することも可能。)
               performSegue(withIdentifier: "Timeline", sender: auth.currentUser!)
           }
       }

       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           let nextViewController = segue.destination as! TimelineViewController
           let user = sender as! User
           nextViewController.me = AppUser(data: ["userID": user.uid])
       }

    // 登録ボタンを押したときに呼ぶメソッド。
    @IBAction func registerAccount() {
        let email = emailTextField.text!
               let password = passwordTextField.text!
               auth.createUser(withEmail: email, password: password) { (result, error) in
                   if error == nil, let result = result {
                       self.performSegue(withIdentifier: "Timeline", sender: result.user)
                   }
               }
    }

// デリゲートメソッドは可読性のためextensionで分けて記述します。
    extension AccountViewController: UITextFieldDelegate {
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    }
}

