//
//  loginViewController.swift
//  pppppp
//
//  Created by 増田ひなた on 2021/07/28.
//

import UIKit
import Firebase

class loginViewController: UIViewController {
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
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
