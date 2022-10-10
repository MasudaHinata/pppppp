import UIKit
import Combine

@MainActor
class EmailSignInViewController: UIViewController, FirebaseClientAuthDelegate {
    
    var cancellables = Set<AnyCancellable>()
    var loginEmailAdress: String?
    
    @IBOutlet var loginLabel: UILabel!
    @IBOutlet var loginButtonLayout: UIButton! {
        didSet {
            var configuration = UIButton.Configuration.filled()
            configuration.title = "Sign In"
            configuration.baseBackgroundColor = Asset.Colors.lightBlue00.color
            configuration.showsActivityIndicator = false
            loginButtonLayout.configuration = configuration
        }
    }
    
    @IBOutlet var emailTextField: UITextField! {
        didSet {
            emailTextField.text = loginEmailAdress
            emailTextField.layer.cornerRadius = 8
            emailTextField.clipsToBounds = true
            emailTextField.layer.cornerCurve = .continuous
        }
    }
    
    @IBOutlet var passwordTextField: UITextField! {
        didSet {
            passwordTextField.layer.cornerRadius = 8
            passwordTextField.clipsToBounds = true
            passwordTextField.layer.cornerCurve = .continuous
        }
    }
    
    @IBAction func goButtonPressed() {
        if passwordTextField.text == "" {
            ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "パスワードが入力されていません")
        } else {
            let task = Task {
                do {
                    try await FirebaseClient.shared.signInWithEmail(email: emailTextField.text ?? "", password: passwordTextField.text ?? "")
                }
                catch {
                    print("EmailSignInView goButtonPressed error:", error.localizedDescription)
                    if error.localizedDescription == "The email address is badly formatted." {
                        ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "メールアドレスの形式が間違っています")
                    }  else if  error.localizedDescription == "There is no user record corresponding to this identifier. The user may have been deleted." {
                        ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "アカウントが存在しません")
                    }else if error.localizedDescription == "The password is invalid or the user does not have a password." {
                        ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "パスワードが間違っているか無効です")
                    } else {
                        ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)")
                    }
                }
            }
            cancellables.insert(.init { task.cancel() })
        }
    }
    
    @IBAction func sentEmailMore() {
        let resetPasswordVC = StoryboardScene.ResetPasswordView.initialScene.instantiate()
        self.showDetailViewController(resetPasswordVC, sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FirebaseClient.shared.loginDelegate = self
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
        self.emailTextField?.delegate = self
        self.passwordTextField?.delegate = self
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    //MARK: - Setting Delegate
    func loginScene() {
        let mainVC = StoryboardScene.Main.initialScene.instantiate()
        self.showDetailViewController(mainVC, sender: self)
    }
}
