import UIKit
import Combine
import AuthenticationServices

@MainActor
class LoginViewController: UIViewController, FirebaseClientAuthDelegate {
    
    var cancellables = Set<AnyCancellable>()
    var loginEmailAdress: String?
    
    @IBOutlet var buttonView: UIView!
    @IBOutlet var loginLabel: UILabel!
    @IBOutlet var loginButtonLayout: UIButton! {
        didSet {
            loginButtonLayout.layer.cornerRadius = 24
            loginButtonLayout.clipsToBounds = true
            loginButtonLayout.layer.cornerCurve = .continuous
            var configuration = UIButton.Configuration.filled()
            configuration.title = "Sign In"
            configuration.baseBackgroundColor = .init(hex: "92B2D3")
            configuration.imagePlacement = .trailing
            configuration.showsActivityIndicator = false
            configuration.imagePadding = 24
            configuration.cornerStyle = .capsule
            loginButtonLayout.configuration = configuration
        }
    }
    
    @IBOutlet var emailTextField: UITextField! {
        didSet {
            emailTextField.text = loginEmailAdress
            emailTextField.layer.cornerRadius = 24
            emailTextField.clipsToBounds = true
            emailTextField.layer.cornerCurve = .continuous
        }
    }
    
    @IBOutlet var passwordTextField: UITextField! {
        didSet {
            passwordTextField.layer.cornerRadius = 24
            passwordTextField.clipsToBounds = true
            passwordTextField.layer.cornerCurve = .continuous
        }
    }
    
    @IBAction func goButtonPressed() {
        if passwordTextField.text == "" {
            showAlert(title: "エラー", message: "パスワードか入力されていません")
        } else {
            let task = Task {
                do {
                    try await FirebaseClient.shared.login(email: emailTextField.text ?? "", password: passwordTextField.text ?? "")
                }
                catch {
                    //TODO: エラーコードでアラートを判別
                    print("LoginView goButtonPressed error:", error.localizedDescription)
                    if error.localizedDescription == "The email address is badly formatted." {
                        showAlert(title: "エラー", message: "メールアドレスの形式が間違っています")
                    }  else if  error.localizedDescription == "There is no user record corresponding to this identifier. The user may have been deleted." {
                        showAlert(title: "エラー", message: "アカウントが存在しません")
                    }else if error.localizedDescription == "The password is invalid or the user does not have a password." {
                        showAlert(title: "エラー", message: "パスワードが間違っているか無効です")
                    } else {
                        showAlert(title: "エラー", message: "\(error.localizedDescription)")
                    }
                }
            }
            cancellables.insert(.init { task.cancel() })
        }
    }
    
    @IBAction func sentEmailMore() {
        let storyboard = UIStoryboard(name: "ResetPasswordView", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "ResetPasswordViewController")
        self.showDetailViewController(secondVC, sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonView.addSubview(signinButton)
        signinButton.fitConstraintsContentView(view: buttonView)
        
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
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    private lazy var signinButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(
            type: .default,
            style: .white
        )
        button.addTarget(
            self,
            action: #selector(handleSignin),
            for: .touchUpInside
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        button.bounds = CGRect(x: 0, y: 0, width: 240, height: 48)
        return button
    }()
    
    @objc private func handleSignin() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    //MARK: - Setting Delegate
    func loginScene() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "TabBarViewController")
        self.showDetailViewController(secondVC, sender: self)
    }
}

//MARK: - extension
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        // AppleIDログイン完了時にはしる処理。サーバにAuth情報を保存したりする。
    }
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "OK",
            style: .default)
        )
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
extension UIView {
    func fitConstraintsContentView(view: UIView? = nil) {
        if let contentView = view == nil ? subviews.first : view {
            NSLayoutConstraint.activate([
                contentView.topAnchor.constraint(equalTo: self.topAnchor),
                contentView.leftAnchor.constraint(equalTo: self.leftAnchor),
                contentView.rightAnchor.constraint(equalTo: self.rightAnchor),
                contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
        }
    }
}
