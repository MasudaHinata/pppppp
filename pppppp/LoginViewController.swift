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
        }
    }
    @IBOutlet var passwordTextField: UITextField! {
        didSet {
            passwordTextField.attributedPlaceholder = NSAttributedString(string: "Enter your Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FirebaseClient.shared.delegateLogin = self
        
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
        
        design()
        
        self.emailTextField?.delegate = self
        self.passwordTextField?.delegate = self
    }
    
    func design() {
        emailTextField.layer.cornerRadius = 24
        emailTextField.clipsToBounds = true
        emailTextField.layer.cornerCurve = .continuous
        passwordTextField.layer.cornerRadius = 24
        passwordTextField.clipsToBounds = true
        passwordTextField.layer.cornerCurve = .continuous
        goButton.layer.cornerRadius = 24
        goButton.clipsToBounds = true
        goButton.layer.cornerCurve = .continuous
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
            print("パスワード入力されてない")
            let alert = UIAlertController(title: "エラー", message: "パスワードか入力されていません", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let task = Task {
                do {
                    try await FirebaseClient.shared.login(email: emailTextField.text ?? "", password: passwordTextField.text ?? "")
                }
                catch {
                    print("LoginView goButtonPressed error:", error.localizedDescription)
                }
            }
            cancellables.insert(.init { task.cancel() })
        }
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
