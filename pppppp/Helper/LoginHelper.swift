import Foundation
import UIKit

@MainActor
class LoginHelper {
    static let shared = LoginHelper()
    private init() {}
    var viewController: UIViewController?
    
    func showAccountViewController() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "EmailSignUpView", bundle: nil)
        let accountVC: EmailSignUpViewController = mainStoryboard.instantiateViewController(withIdentifier: "EmailSignUpViewController") as! EmailSignUpViewController
        viewController?.present(accountVC, animated: true, completion: nil)
    }
}
