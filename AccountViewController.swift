import UIKit
import Firebase

class AccountViewController: UIViewController {

    var auth: Auth!
    
    @IBOutlet var EmailTextField: UITextField! {
        didSet {
            EmailTextField.layer.cornerRadius = 16
            EmailTextField.layer.cornerCurve = .continuous
            EmailTextField.attributedPlaceholder = NSAttributedString(string: "Enter your Password", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        }
    }

  
    @IBOutlet var PasswordTextField: UITextField! {
        didSet{
            PasswordTextField.layer.cornerRadius = 16
            PasswordTextField.layer.cornerCurve = .continuous
            PasswordTextField.attributedPlaceholder = NSAttributedString(string: "Enter your email address", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        }
    }
    
    @IBAction func LoginButton() {
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        auth = Auth.auth()
        EmailTextField.delegate = self
        PasswordTextField.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if auth.currentUser != nil {
            auth.currentUser?.reload(completion: { error in
                if error == nil {
                    if self.auth.currentUser?.isEmailVerified == true {
                        self.performSegue(withIdentifier: "Timeline", sender: self.auth.currentUser!)
                    } else if self.auth.currentUser?.isEmailVerified == false {
                        let alert = UIAlertController(title: "確認用メールを送信しているので確認をお願いします。", message: "まだメール認証が完了していません。", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            })
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextViewController = segue.destination as? ViewController{
            let user = sender as! User
            nextViewController.me = AppUser(data: ["userID": user.uid])
        }
    }

    @IBAction func registerAccount() {
        let email = EmailTextField.text!
        let password = PasswordTextField.text!
        auth.createUser(withEmail: email, password: password) { (result, error) in
            if error == nil, let result = result {
                result.user.sendEmailVerification(completion: { (error) in
                    if error == nil {
                        let alert = UIAlertController(title: "仮登録を行いました。", message: "入力したメールアドレス宛に確認メールを送信しました。", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            } else {
                print("error occured")
                print(error)
            }
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
