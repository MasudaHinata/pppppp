import Foundation
import UIKit

@MainActor
class LoginHelper {
    static let shared = LoginHelper()
    private init() {}
    var viewController: UIViewController?
    
    func showAccountViewController() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "FirstView", bundle: nil)
        let accountVC: FirstViewController = mainStoryboard.instantiateInitialViewController() as! FirstViewController
        viewController?.present(accountVC, animated: true, completion: nil)
    }
}
