import UIKit
import Firebase // Firebaseをインポート

class AccountViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }

　  // 登録ボタンを押したときに呼ぶメソッド。
    @IBAction func registerAccount() {

    }
}

// デリゲートメソッドは可読性のためextensionで分けて記述します。
extension AccountViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
