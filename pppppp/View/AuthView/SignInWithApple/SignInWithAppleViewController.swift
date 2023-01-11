import UIKit
import AuthenticationServices
import CryptoKit
import FirebaseAuth
import SafariServices

class SignInWithAppleViewController: UIViewController {
    
    @IBOutlet var AppleLoginButtonView: UIView!
    
    @IBOutlet var privacyPolicyButtonLayout: UIButton! {
        didSet {
            privacyPolicyButtonLayout.tintColor = Asset.Colors.white48.color
        }
    }
    
    @IBAction func sceneEmailSignInButton() {
        let emailSignInVC = StoryboardScene.EmailSignInView.initialScene.instantiate()
        self.showDetailViewController(emailSignInVC, sender: self)
    }
    
    @IBAction func privacyPolicyButton() {
        guard let url = URL(string: "https://peraichi.com/landing_pages/view/7zjul") else { return }
        let safariController = SFSafariViewController(url: url)
        present(safariController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppleLoginButtonView.addSubview(signinButton)
        signinButton.fitConstraintsContentView(view: AppleLoginButtonView)
    }
    
    //MARK: - Sign In With Apple
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
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    fileprivate var currentNonce: String?
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
}

//MARK: - Sign In With Apple
extension SignInWithAppleViewController: ASAuthorizationControllerDelegate {
    
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
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if (error != nil) {
                    print(error!.localizedDescription)
                    return
                }
                let mainVC = StoryboardScene.Main.initialScene.instantiate()
                self.showDetailViewController(mainVC, sender: self)
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
    
}
extension SignInWithAppleViewController: ASAuthorizationControllerPresentationContextProviding {
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
