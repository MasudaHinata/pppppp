import Foundation
import UIKit

@MainActor
class LoginHelper {
    static let shared = LoginHelper()
    private init() {}
    var viewController: UIViewController?
    
    func showAccountViewController() {
        let secondVC = StoryboardScene.SignInWithAppleView.initialScene.instantiate()
        viewController?.present(secondVC, animated: true, completion: nil)
    }
}
