import Foundation
import UIKit

@MainActor
class ErrorHelper {
    static let shared = ErrorHelper()
    private init() {}
    
    var viewController: UIViewController?
    func showAlert(title: String, messege: String) {
        let alert = UIAlertController(title: title, message: messege, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default)
        alert.addAction(ok)
        viewController?.present(alert, animated: true, completion: nil)
    }
}
