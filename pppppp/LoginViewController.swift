import UIKit
import Combine

@MainActor
class LoginViewController: UIViewController, UITextFieldDelegate ,FirebaseClientAuthDelegate {
    
    var cancellables = Set<AnyCancellable>()
    @IBOutlet var goButton: UIButton!
    @IBOutlet var loginLabel: UILabel!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FirebaseClient.shared.delegateLogin = self
        
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
        
        
        goButton.layer.cornerRadius = 24
        goButton.clipsToBounds = true
        goButton.layer.cornerCurve = .continuous
        
        self.emailTextField?.delegate = self
        self.passwordTextField?.delegate = self
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
                    self!.present(alert, animated: true)
                    print("LoginView goButtonPressed error:", error.localizedDescription)
                }
            }
            cancellables.insert(.init { task.cancel() })
        }
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
