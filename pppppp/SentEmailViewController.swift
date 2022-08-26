//
//  SentEmailViewController.swift
//  pppppp
//
//  Created by hinata on 2022/08/27.
//

import UIKit
import Combine

class SentEmailViewController: UIViewController {
    
    var cancellables = Set<AnyCancellable>()
    @IBOutlet var goButton: UIButton! {
        didSet {
            goButton.layer.cornerRadius = 24
            goButton.clipsToBounds = true
            goButton.layer.cornerCurve = .continuous
        }
    }
    @IBOutlet var emailTextField: UITextField! {
        didSet {
            emailTextField.attributedPlaceholder = NSAttributedString(string: "Enter your EmailAddress", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            emailTextField.layer.cornerRadius = 24
            emailTextField.clipsToBounds = true
            emailTextField.layer.cornerCurve = .continuous
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func sentEmailMore() {
        
        if let email = emailTextField.text, emailTextField.text != "" {
            let task = Task {
                do {
                    try await FirebaseClient.shared.passwordResetting(email: email)
                    //ここで呼ぶのやめる
                    dismiss(animated: true, completion: nil)
                }
                catch {
                    let alert = UIAlertController(title: "エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(action)
                    self.present(alert, animated: true)
                    print("SentEmail sentEmailMore error:", error.localizedDescription)
                }
            }
            cancellables.insert(.init { task.cancel() })
        } else {
            let alert = UIAlertController(title: "エラー", message: "メールアドレスを入力してください", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default)
            alert.addAction(action)
            self.present(alert, animated: true)
        }
    }
}
