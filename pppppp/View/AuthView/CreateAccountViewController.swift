import UIKit
import Combine
import AuthenticationServices
import CryptoKit
import Firebase

class CreateAccountViewController: UIViewController, FirebaseCreatedAccountDelegate {
    
    var cancellables = Set<AnyCancellable>()
    
    @IBOutlet var AppleLoginButtonView: UIView!
    @IBOutlet var goButtonLayout: UIButton! {
        didSet {
            var configuration = UIButton.Configuration.filled()
            configuration.title = "Sign Up"
            configuration.baseBackgroundColor = .init(hex: "92B2D3")
            configuration.imagePlacement = .trailing
            configuration.showsActivityIndicator = false
            configuration.imagePadding = 24
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
    @IBOutlet var passwordTextField: UITextField! {
        didSet {
            passwordTextField.layer.cornerRadius = 8
            passwordTextField.clipsToBounds = true
            passwordTextField.layer.cornerCurve = .continuous
        }
    }
    @IBOutlet var password2TextField: UITextField! {
        didSet {
            password2TextField.layer.cornerRadius = 8
            password2TextField.clipsToBounds = true
            password2TextField.layer.cornerCurve = .continuous
        }
    }
    
    @IBAction func GooButton() {
        if passwordTextField.text == password2TextField.text {
            var configuration = UIButton.Configuration.filled()
            configuration.title = "Creating Account..."
            configuration.baseBackgroundColor = .init(hex: "92B2D3")
            configuration.showsActivityIndicator = true
            configuration.imagePadding = 24
            configuration.imagePlacement = .trailing
            goButtonLayout.configuration = configuration
            let email = self.emailTextField.text!
            let password = self.passwordTextField.text!
            
            let task = Task {
                do {
                    try await FirebaseClient.shared.createAccount(email: email, password: password)
                }
                catch {
                    print("Account checkPassword error:",error.localizedDescription)
                    //TODO: エラーコードでアラートを判別
                    if error.localizedDescription == "An email address must be provided." {
                        showAlert(title: "エラー", message: "メールアドレスを入力してください")
                    } else if error.localizedDescription == "The email address is badly formatted." {
                        showAlert(title: "エラー", message: "メールアドレスの形式が間違っています")
                    } else if error.localizedDescription == "The password must be 6 characters long or more." {
                        showAlert(title: "エラー", message: "パスワードは６文字以上に設定してください")
                    } else if error.localizedDescription == "The email address is already in use by another account." {
                        showAlert(title: "エラー", message: "このメールアドレスは登録済みです")
                    } else {
                        showAlert(title: "エラー", message: "\(error.localizedDescription)")
                    }
                }
                var configuration = UIButton.Configuration.gray()
                configuration.title = "Sign up"
                configuration.baseBackgroundColor = .init(hex: "92B2D3")
                configuration.imagePlacement = .trailing
                configuration.baseForegroundColor = .white
                configuration.imagePadding = 24
                self.goButtonLayout.configuration = configuration
            }
            cancellables.insert(.init { task.cancel() })
        } else if passwordTextField.text != password2TextField.text {
            showAlert(title: "エラー", message: "パスワードが一致しません")
        }
    }
    
    @IBAction func LoginButton () {
        let storyboard = UIStoryboard(name: "LoginView", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "LoginViewController")
        self.showDetailViewController(secondVC, sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AppleLoginButtonView.addSubview(signinButton)
        signinButton.fitConstraintsContentView(view: AppleLoginButtonView)
        
        FirebaseClient.shared.createdAccountDelegate = self
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.password2TextField.delegate = self
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    //MARK: - AppleLogin
    //TODO: FirebaseClientに移行
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError(
              "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }
      return result
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }
    
    fileprivate var currentNonce: String?
    @available(iOS 13, *)
    func startSignInWithAppleFlow() {
      let nonce = randomNonceString()
      currentNonce = nonce
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]
      request.nonce = sha256(nonce)

      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = self
      authorizationController.performRequests()
    }
        
    private lazy var signinButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(type: .default, style: .white)
        button.addTarget(self, action: #selector(handleSignin), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.bounds = CGRect(x: 0, y: 0, width: 240, height: 48)
        return button
    }()

    @objc private func handleSignin() {
        startSignInWithAppleFlow()
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    //MARK: - Setting Delegate
    func accountCreated() {
        let alert = UIAlertController(title: "仮登録メールを送信しました", message: "メールを確認してください", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            let storyboard = UIStoryboard(name: "LoginView", bundle: nil)
            let secondVC = storyboard.instantiateViewController(identifier: "LoginViewController") as? LoginViewController
            secondVC!.loginEmailAdress = self.emailTextField.text
            self.showDetailViewController(secondVC!, sender: self)
        }
        alert.addAction(ok)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

//MARK: - extension
extension CreateAccountViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        password2TextField.resignFirstResponder()
        return true
    }
}

//MARK: - AppleLogin
@available(iOS 13.0, *)
extension CreateAccountViewController: ASAuthorizationControllerDelegate {

  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
      guard let nonce = currentNonce else {
        fatalError("Invalid state: A login callback was received, but no login request was sent.")
      }
      guard let appleIDToken = appleIDCredential.identityToken else {
        print("Unable to fetch identity token")
        return
      }
      guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
        print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
        return
      }
      // Initialize a Firebase credential.
      let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                idToken: idTokenString,
                                                rawNonce: nonce)
      // Sign in with Firebase.
      Auth.auth().signIn(with: credential) { (authResult, error) in
          if (error != nil) {
          // Error. If error.code == .MissingOrInvalidNonce, make sure
          // you're sending the SHA256-hashed nonce as a hex string with
          // your request to Apple.
            print(error!.localizedDescription)
          return
        }
        // User is signed in to Firebase with Apple.
        // ...
          let storyboard = UIStoryboard(name: "Main", bundle: nil)
          let secondVC = storyboard.instantiateViewController(identifier: "TabBarViewController")
          self.showDetailViewController(secondVC, sender: self)
      }
    }
  }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // Handle error.
    print("Sign in with Apple errored: \(error)")
  }

}
extension CreateAccountViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
