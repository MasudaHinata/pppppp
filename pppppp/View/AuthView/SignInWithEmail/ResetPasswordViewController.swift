import UIKit
import Combine

class ResetPasswordViewController: UIViewController, FirebaseSentEmailDelegate {
    
    var cancellables = Set<AnyCancellable>()
    
    @IBOutlet var goButtonLayout: UIButton! {
        didSet {
            var configuration = UIButton.Configuration.filled()
            configuration.title = "Reset password"
            configuration.baseBackgroundColor = .init(hex: "92B2D3")
            configuration.showsActivityIndicator = false
            goButtonLayout.configuration = configuration
        }
    }
    
    @IBOutlet var emailTextField: UITextField! {
        didSet {
            emailTextField.layer.cornerRadius = 8
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
            goButtonLayout.configuration = configuration
            
            let task = Task { [weak self] in
                guard let self = self else { return }
                do {
                    try await FirebaseClient.shared.passwordResetting(email: email)
                }
                catch {
                    print("SentEmail sentEmailMore error:", error.localizedDescription)
                    if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                        ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "インターネット接続を確認してください", handler: { (_) in })
                    } else {
                        ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)", handler: { (_) in })
                    }
                }
                var configuration = UIButton.Configuration.gray()
                configuration.title = "Reset password"
                configuration.baseBackgroundColor = .init(hex: "92B2D3")
                configuration.baseForegroundColor = .white
                self.goButtonLayout.configuration = configuration
            }
            cancellables.insert(.init { task.cancel() })
        } else {
            ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "メールアドレスを入力してください", handler: { (_) in })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseClient.shared.sentEmailDelegate = self
        
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
        self.emailTextField?.delegate = self
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    //MARK: - Setting Delegate
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
}
