import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var goButton: UIButton!
    @IBOutlet var loginLabel: UILabel!
    var auth: Auth!
    
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
        
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
        
        design()
        auth = Auth.auth()
        
        self.emailTextField?.delegate = self
        self.passwordTextField?.delegate = self
    }
    
    func design() {
        emailTextField.layer.cornerRadius = 24
        passwordTextField.layer.cornerRadius = 24
        emailTextField.clipsToBounds = true
        passwordTextField.clipsToBounds = true
        goButton.layer.cornerRadius = 24
        goButton.clipsToBounds = true
    }
    
    @IBAction func goButtonPressed() {
        auth.signIn(withEmail: emailTextField.text ?? "", password: passwordTextField.text ?? "") { [weak self] authResult, error in
            guard let self = self else { return }
            if self.auth.currentUser?.isEmailVerified == true {
                print("パスワードとメールアドレス一致")
                self.performSegue(withIdentifier: "toViewController", sender: nil)
            } else if self.passwordTextField.text == "" {
                print("パスワード入力されてない")
                let alert = UIAlertController(title: "エラー", message: "パスワードを確認してください", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            } else if self.auth.currentUser?.isEmailVerified == nil {
                print("パスワードかメールアドレスが間違っています")
                let alert = UIAlertController(title: "パスワードかメールアドレスが間違っています。", message: "パスワードかメールアドレスを確認してください", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
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
