import UIKit
import Combine

@MainActor
class LoginViewController: UIViewController, UITextFieldDelegate ,FirebaseClientAuthDelegate {
    
    var cancellables = Set<AnyCancellable>()
    @IBOutlet var loginButtonLayout: UIButton! {
        didSet {
            loginButtonLayout.layer.cornerRadius = 24
            loginButtonLayout.clipsToBounds = true
            loginButtonLayout.layer.cornerCurve = .continuous
            var configuration = UIButton.Configuration.filled()
            configuration.title = "Sign In"
            configuration.baseBackgroundColor = .init(hex: "92B2D3")
            configuration.imagePlacement = .trailing
            configuration.showsActivityIndicator = false
            configuration.imagePadding = 24
            configuration.cornerStyle = .capsule
            loginButtonLayout.configuration = configuration
        }
    }
    @IBOutlet var loginLabel: UILabel!
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
    @IBAction func goButtonPressed() {
        if passwordTextField.text == "" {
            showAlert(title: "エラー", message: "パスワードか入力されていません")
        } else {
            let task = Task {
                do {
                    try await FirebaseClient.shared.login(email: emailTextField.text ?? "", password: passwordTextField.text ?? "")
                }
                catch {
                    let alert = UIAlertController(title: "エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(action)
                    self.present(alert, animated: true)
                    print("LoginView goButtonPressed error:", error.localizedDescription)
                }
            }
            cancellables.insert(.init { task.cancel() })
        }
    }
    @IBAction func sentEmailMore() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "SentEmailViewController")
        self.showDetailViewController(secondVC, sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseClient.shared.loginDelegate = self
        self.emailTextField?.delegate = self
        self.passwordTextField?.delegate = self
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
    }
    func loginHelperAlert() {
        let alert = UIAlertController(title: "パスワードかメールアドレスが間違っています", message: "パスワードかメールアドレスを確認してください", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    func loginScene() {
        self.performSegue(withIdentifier: "toViewController", sender: nil)
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
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
}
