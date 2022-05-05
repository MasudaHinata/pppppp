import UIKit
import Firebase

class AccountViewController: UIViewController ,UITextFieldDelegate {
    
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
    @IBOutlet var GoButton: UIButton!
    
    @IBAction func LoginButton () {
        self.performSegue(withIdentifier: "toLogin", sender: nil)
    }
    
    @IBAction func GooButton() {
        
//        if self.isValidEmail(self.emailTextField.text!){
//            // メールアドレスが正しく入力された場合
//            registerAccount()
//        } else {
//            // メールアドレスが正しく入力されなかった場合
//            print("メールアドレスの形式が間違っています")
//            let alert = UIAlertController(title: "メールアドレスの形式が間違っています", message: "メールアドレスを確認してください", preferredStyle: .alert)
//            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
////                self.dismiss(animated: true, completion: nil)
//            }
//            alert.addAction(ok)
//            present(alert, animated: true, completion: nil)
//        }

        if self.isValidEmail(self.emailTextField.text!){
            // メールアドレスが正しく入力された場合
            register()
        } else {
            // メールアドレスが正しく入力されなかった場合
            print("メールアドレスの形式が間違っています")
            let alert = UIAlertController(title: "メールアドレスの形式が間違っています", message: "メールアドレスを確認してください", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
//                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
        

    }
    
    func register () {
        if passwordTextField.text == password2TextField.text {
            registerAccount()
        }else if passwordTextField.text == "" {
            print("パスワードが入力されていない")
            let alert = UIAlertController(title: "パスワードが入力されていません", message: "パスワードを入力してください", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
//                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }else if passwordTextField.text != password2TextField.text {
            let alert = UIAlertController(title: "パスワードが一致しません", message: "パスワードを確認してください", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
//                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }

    }
    
    
    
        
    override func viewDidLoad() {
        design()
        super.viewDidLoad()
        auth = Auth.auth()
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.password2TextField.delegate = self
    }
    
    func registerAccount() {
        let email = emailTextField.text!
        let password = passwordTextField.text!
    
        auth.createUser(withEmail: email, password: password) { (result, error) in
            if error == nil, let result = result {
                result.user.sendEmailVerification(completion: { (error) in
                    if error == nil {
                        let alert = UIAlertController(title: "仮登録を行いました。", message: "入力したメールアドレス宛に確認メールを送信しました。", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        self.performSegue(withIdentifier: "toLogin", sender: nil)
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
    
    func isValidEmail(_ string: String) -> Bool {
            let emailRegEx = "[A-Z0-9a-z._+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            let result = emailTest.evaluate(with: string)
            return result
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
    
   func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        password2TextField.resignFirstResponder()
            return true
    }
   
}
