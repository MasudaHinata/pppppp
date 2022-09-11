import UIKit
import Combine

class CreateAccountViewController: UIViewController, FirebaseCreatedAccountDelegate {
    
    var cancellables = Set<AnyCancellable>()
    @IBOutlet var goButtonLayout: UIButton! {
        didSet {
            var configuration = UIButton.Configuration.filled()
            configuration.title = "Sign Up"
            configuration.baseBackgroundColor = .init(hex: "92B2D3")
            configuration.imagePlacement = .trailing
            configuration.showsActivityIndicator = false
            configuration.imagePadding = 24
            configuration.cornerStyle = .capsule
            goButtonLayout.configuration = configuration
        }
    }
    
    @IBOutlet var emailTextField: UITextField! {
        didSet {
            emailTextField.layer.cornerRadius = 24
            emailTextField.clipsToBounds = true
            emailTextField.layer.cornerCurve = .continuous
        }
    }
    @IBOutlet var passwordTextField: UITextField! {
        didSet {
            passwordTextField.layer.cornerRadius = 24
            passwordTextField.clipsToBounds = true
            passwordTextField.layer.cornerCurve = .continuous
        }
    }
    @IBOutlet var password2TextField: UITextField! {
        didSet {
            password2TextField.layer.cornerRadius = 24
            password2TextField.clipsToBounds = true
            password2TextField.layer.cornerCurve = .continuous
        }
    }
    
    @IBAction func GooButton() {
        if passwordTextField.text == password2TextField.text {
            var configuration = UIButton.Configuration.filled()
            configuration.title = "Creating Account..."
            configuration.baseBackgroundColor = .init(hex: "92B2D3")
            configuration.showsActivityIndicator = true
            configuration.imagePadding = 24
            configuration.imagePlacement = .trailing
            configuration.cornerStyle = .capsule
            goButtonLayout.configuration = configuration
            let email = self.emailTextField.text!
            let password = self.passwordTextField.text!
            
            let task = Task {
                do {
                    try await FirebaseClient.shared.createAccount(email: email, password: password)
                }
                catch {
                    print("Account checkPassword error:",error.localizedDescription)
                    //TODO: エラーコードでエラー処理をする
                    if error.localizedDescription == "An email address must be provided." {
                        showAlert(title: "エラー", message: "メールアドレスを入力してください")
                    } else if error.localizedDescription == "The email address is badly formatted." {
                        showAlert(title: "エラー", message: "メールアドレスの形式が間違っています")
                    } else if error.localizedDescription == "The password must be 6 characters long or more." {
                        showAlert(title: "エラー", message: "パスワードは６文字以上に設定してください")
                    } else if error.localizedDescription == "The email address is already in use by another account." {
                        showAlert(title: "エラー", message: "このメールアドレスは登録済みです")
                    } else {
                        showAlert(title: "エラー", message: "\(error.localizedDescription)")
                    }
                }
                var configuration = UIButton.Configuration.gray()
                configuration.title = "Sign up"
                configuration.baseBackgroundColor = .init(hex: "92B2D3")
                configuration.cornerStyle = .capsule
                configuration.imagePlacement = .trailing
                configuration.baseForegroundColor = .white
                configuration.imagePadding = 24
                self.goButtonLayout.configuration = configuration
            }
            cancellables.insert(.init { task.cancel() })
        } else if passwordTextField.text != password2TextField.text {
            showAlert(title: "エラー", message: "パスワードが一致しません")
        }
    }
    
    @IBAction func LoginButton () {
        let storyboard = UIStoryboard(name: "LoginView", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "LoginViewController")
        self.showDetailViewController(secondVC, sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseClient.shared.createdAccountDelegate = self
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.password2TextField.delegate = self
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    //MARK: - Setting Delegate
    func accountCreated() {
        let alert = UIAlertController(title: "仮登録メールを送信しました", message: "メールを確認してください", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            let storyboard = UIStoryboard(name: "LoginView", bundle: nil)
            let secondVC = storyboard.instantiateViewController(identifier: "LoginViewController") as? LoginViewController
            secondVC!.loginEmailAdress = self.emailTextField.text
            self.showDetailViewController(secondVC!, sender: self)
        }
        alert.addAction(ok)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

//MARK: - extension
extension CreateAccountViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        password2TextField.resignFirstResponder()
        return true
    }
}

