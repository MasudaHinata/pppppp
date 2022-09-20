import Foundation
import UIKit

@MainActor
class LoginHelper {
    static let shared = LoginHelper()
    private init() {}
    var viewController: UIViewController?
    
    func showAccountViewController() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "SignInWithAppleView", bundle: nil)
        let accountVC: SignInWithAppleViewController = mainStoryboard.instantiateInitialViewController() as! SignInWithAppleViewController
        viewController?.present(accountVC, animated: true, completion: nil)
    }
}
