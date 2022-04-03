import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet var LoginButton: UIButton!
    
    @IBOutlet var emailTextField: UITextField! {
        didSet {
            emailTextField.attributedPlaceholder = NSAttributedString(string: "Enter your EmailAddress", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            emailTextField.layer.cornerRadius = 24
            emailTextField.clipsToBounds = true
        }
    }
    @IBOutlet var passwordTextField: UITextField! {
        didSet {
            passwordTextField.attributedPlaceholder = NSAttributedString(string: "Enter your Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            passwordTextField.layer.cornerRadius = 24
            passwordTextField.clipsToBounds = true
        }
    }
    
    @IBOutlet var goButton: UIButton! {
        didSet {
            goButton.layer.cornerRadius = 24
            goButton.layer.cornerCurve = .continuous
        }
    }
    
    var auth: Auth!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        auth = Auth.auth()
    }
   
    @IBAction func loginButtonPressed() {
        Auth.auth().signIn(withEmail: emailTextField.text ?? "", password: passwordTextField.text ?? "") { [weak self] authResult, error in
          guard let self = self else { return }
            
            if error == nil {
                if self.auth.currentUser?.isEmailVerified == true {
                    self.performSegue(withIdentifier: "Timeline", sender: self.auth.currentUser!)
                } else if self.auth.currentUser?.isEmailVerified == false {
                    let alert = UIAlertController(title: "パスワードかメールアドレスが間違っています", message: "確認し直してください", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
