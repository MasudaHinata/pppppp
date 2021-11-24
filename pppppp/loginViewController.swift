import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    var auth: Auth!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        design()
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
    
    func design() {
        emailTextField.layer.cornerRadius = 24
        passwordTextField.layer.cornerRadius = 24
        emailTextField.clipsToBounds = true
        passwordTextField.clipsToBounds = true
    }
}
