import UIKit
import FirebaseStorage
import Combine

class AccountViewController: UIViewController ,UITextFieldDelegate {
    
    var cancellables = Set<AnyCancellable>()
    @IBOutlet var GoButton: UIButton!
    @IBOutlet var emailTextField: UITextField! {
        didSet {
            emailTextField.attributedPlaceholder = NSAttributedString(string: "Enter your EmailAddress", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            emailTextField.layer.cornerRadius = 24
            emailTextField.clipsToBounds = true
            emailTextField.layer.cornerCurve = .continuous
        }
    }
    @IBOutlet var passwordTextField: UITextField! {
        didSet {
            passwordTextField.attributedPlaceholder = NSAttributedString(string: "Enter your Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            passwordTextField.layer.cornerRadius = 24
            passwordTextField.clipsToBounds = true
            passwordTextField.layer.cornerCurve = .continuous
        }
    }
    @IBOutlet var password2TextField: UITextField! {
        didSet {
            password2TextField.attributedPlaceholder = NSAttributedString(string: "confirm your Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            password2TextField.layer.cornerRadius = 24
            password2TextField.clipsToBounds = true
            password2TextField.layer.cornerCurve = .continuous
        }
    }
    
    @IBAction func GooButton() {
        if self.isValidEmail(self.emailTextField.text!) {
            print("メールアドレスok")
            checkpassword()
        } else {
            // メールアドレスが正しく入力されなかった場合
            print("メールアドレスの形式が間違っています")
            let alert = UIAlertController(title: "メールアドレスの形式が間違っています", message: "メールアドレスを確認してください", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            }
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
        
        GoButton.layer.cornerRadius = 24
        GoButton.clipsToBounds = true
        GoButton.layer.cornerCurve = .continuous
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.password2TextField.delegate = self
    }
    //②
    func checkpassword() {
        if passwordTextField.text == password2TextField.text && passwordTextField.text != "" {
            print("パスワードok")
            let email = self.emailTextField.text!
            let password = self.passwordTextField.text!
            
            let task = Task {
                do {
                    FirebaseClient.shared.createAccount(email: email, password: password)
                }
                catch {
                    print("check password error:,",error.localizedDescription)
                }
            }
            cancellables.insert(.init { task.cancel() })
            //ここで呼ぶのやめる
            let alert = UIAlertController(title: "仮登録を行いました", message: "入力したメールアドレス宛に確認メールを送信しました。", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { [self] (action) in
                print("仮登録完了")
            }
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        } else if passwordTextField.text == "" {
            print("パスワードが入力されていない")
            let alert = UIAlertController(title: "パスワードが入力されていません", message: "パスワードを入力してください", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            }
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        } else if passwordTextField.text != password2TextField.text {
            let alert = UIAlertController(title: "パスワードが一致しません", message: "パスワードを確認してください", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            }
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        password2TextField.resignFirstResponder()
        return true
    }
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    @IBAction func LoginButton () {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "LoginViewController")
        self.showDetailViewController(secondVC, sender: self)
    }
    func isValidEmail(_ string: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: string)
        return result
    }
}
