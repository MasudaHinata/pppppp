import UIKit
import Firebase

class AccountViewController: UIViewController {
    
    var auth: Auth!

    @IBOutlet var emailTextField: UITextField! {
        didSet {
            emailTextField.attributedPlaceholder = NSAttributedString(string: "Enter your EmailAddress", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
    }
    @IBOutlet var passwordTextField: UITextField! {
        didSet {
            passwordTextField.attributedPlaceholder = NSAttributedString(string: "confirm your Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
    }
    
    @IBOutlet var password2TextField: UITextField! {
        didSet {
            password2TextField.attributedPlaceholder = NSAttributedString(string: "Enter your Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
    }
    
    @IBOutlet var welcomeLabel: UILabel!
    @IBOutlet var LoginButton: UIButton!
    @IBOutlet var label: UILabel!
    @IBOutlet var GoButton: UIButton!
    @IBAction func GooButton() {
        
        if passwordTextField.text == password2TextField.text {
            registerAccount()
        };if passwordTextField.text == "" {
            let alert = UIAlertController(title: "パスワードを入力してください", message: "パスワードを確認してください", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        };if passwordTextField.text != password2TextField.text {
            let alert = UIAlertController(title: "パスワードが一致しません", message: "パスワードを確認してください", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func button() {
        if auth.currentUser == nil {
            label.text = "ログインしてない"
        }else{
            label.text = "ログイン中"
        }
    }
    
    override func viewDidLoad() {
        design()
        super.viewDidLoad()
        auth = Auth.auth()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        
    }
    @IBAction func registerAccount() {
        let email = emailTextField.text!
        let password = passwordTextField.text!
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
    
    func design() {
        emailTextField.layer.cornerRadius = 24
        passwordTextField.layer.cornerRadius = 24
        password2TextField.layer.cornerRadius = 24
        emailTextField.clipsToBounds = true
        passwordTextField.clipsToBounds = true
        password2TextField.clipsToBounds = true
        GoButton.layer.cornerRadius = 24
        GoButton.clipsToBounds = true
    }
    
    
    
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        if auth.currentUser != nil {
//            auth.currentUser?.reload(completion: { error in
//                 if self.auth.currentUser?.isEmailVerified == false {
//                        let alert = UIAlertController(title: "確認用メールを送信しているので確認をお願いします。", message: "まだメール認証が完了していません。", preferredStyle: .alert)
//                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                        self.present(alert, animated: true, completion: nil)
//                    }
//            })
//        }
//    }
    
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "toTimeline" {
//            let user = self.auth.currentUser
//            let nextViewController = segue.destination as! ViewController
//            nextViewController.me = user
//        }
//    }
    
   
}


// デリゲートメソッドは可読性のためextensionで分けて記述します。
extension AccountViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
