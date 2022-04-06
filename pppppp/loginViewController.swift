import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet var createAcoountButton: UIButton!
    @IBOutlet var goButton: UIButton!
    @IBOutlet var loginLabel: UILabel!
    @IBOutlet var label: UILabel!
    var auth: Auth!
    
    
    @IBOutlet var emailTextField: UITextField! {
        didSet {
            emailTextField.attributedPlaceholder = NSAttributedString(string: "Enter your EmailAddress", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 255, green: 255, blue: 255, alpha: 0.5)])
        }
    }
    @IBOutlet var passwordTextField: UITextField! {
        didSet {
            passwordTextField.attributedPlaceholder = NSAttributedString(string: "Enter your Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
    }
    
    @IBAction func button() {
        if auth.currentUser == nil {
            label.text = "ログインしてない"
        }else {
            label.text = "ログイン中"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        design()
        auth = Auth.auth()
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
        Auth.auth().signIn(withEmail: emailTextField.text ?? "", password: passwordTextField.text ?? "") { [weak self] authResult, error in
          guard let self = self else { return }
            
        if error != nil {
                if self.auth.currentUser?.isEmailVerified == true {
                    print("あってる！！！")
                    self.performSegue(withIdentifier: "toTimeline", sender: self.auth.currentUser!)
                } else {
                    print("パスワードかメールアドレスが間違っています")
                    let alert = UIAlertController(title: "パスワードかメールアドレスが間違っています", message: "パスワードかメールアドレスを確認してください。", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
}
