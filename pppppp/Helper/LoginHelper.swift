import Foundation
import UIKit

@MainActor
class LoginHelper {
    static let shared = LoginHelper()
    private init() {}
    var viewController: UIViewController?
    
    func showAccountViewController() {
        let signInWithAppleVC = StoryboardScene.SignInWithAppleView.initialScene.instantiate()
        viewController?.present(signInWithAppleVC, animated: true, completion: nil)
    }
}
