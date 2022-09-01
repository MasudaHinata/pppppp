//
//  ResetPasswordViewController.swift
//  pppppp
//
//  Created by hinata on 2022/08/27.
//

import UIKit
import Combine

class ResetPasswordViewController: UIViewController, FirebaseSentEmailDelegate {
    
    var cancellables = Set<AnyCancellable>()
    @IBOutlet var goButtonLayout: UIButton! {
        didSet {
            goButtonLayout.layer.cornerRadius = 24
            goButtonLayout.clipsToBounds = true
            goButtonLayout.layer.cornerCurve = .continuous
            var configuration = UIButton.Configuration.filled()
            configuration.title = "Reset password"
            configuration.baseBackgroundColor = .init(hex: "92B2D3")
            configuration.imagePlacement = .trailing
            configuration.showsActivityIndicator = false
            configuration.imagePadding = 24
            configuration.cornerStyle = .capsule
            goButtonLayout.configuration = configuration
        }
    }
    @IBOutlet var emailTextField: UITextField! {
        didSet {
            emailTextField.layer.cornerRadius = 24
            emailTextField.clipsToBounds = true
            emailTextField.layer.cornerCurve = .continuous
        }
    }
    @IBAction func sentEmail() {
        if let email = emailTextField.text, emailTextField.text != "" {
            var configuration = UIButton.Configuration.filled()
            configuration.title = "Sent Email..."
            configuration.baseBackgroundColor = .init(hex: "92B2D3")
            configuration.showsActivityIndicator = true
            configuration.imagePadding = 24
            configuration.imagePlacement = .trailing
            configuration.cornerStyle = .capsule
            goButtonLayout.configuration = configuration
            
            let task = Task {
                do {
                    try await FirebaseClient.shared.passwordResetting(email: email)
                }
                catch {
                    let alert = UIAlertController(title: "エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(action)
                    self.present(alert, animated: true)
                    print("SentEmail sentEmailMore error:", error.localizedDescription)
                }
                var configuration = UIButton.Configuration.gray()
                configuration.title = "Reset password"
                configuration.baseBackgroundColor = .init(hex: "92B2D3")
                configuration.cornerStyle = .capsule
                configuration.imagePlacement = .trailing
                configuration.baseForegroundColor = .white
                configuration.imagePadding = 24
                self.goButtonLayout.configuration = configuration
            }
            cancellables.insert(.init { task.cancel() })
        } else {
            let alert = UIAlertController(title: "エラー", message: "メールアドレスを入力してください", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default)
            alert.addAction(action)
            self.present(alert, animated: true)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseClient.shared.sentEmailDelegate = self
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
    }
    func sendEmail() {
        let alert = UIAlertController(title: "完了", message: "パスワード再設定メールを送信しました", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(ok)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        return true
    }
}
