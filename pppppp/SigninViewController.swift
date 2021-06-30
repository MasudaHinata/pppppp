//
//  ViewController.swift
//  pppppp
//
//  Created by Masakaz Ozaki on 2021/06/30.
//

import UIKit
import Firebase

class SigninViewController: UIViewController {

    @IBAction func signinPressed(_ sender: Any){
            guard let email = roginemailTextField.text else {return}
            guard let password = roginpasswordTextField.text else {return}

            Auth.auth().signIn(withEmail: email, password: password){(user,error) in
            }
        }
    @IBOutlet var roginemailTextField: UITextField!
    @IBOutlet var roginpasswordTextField: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
}
