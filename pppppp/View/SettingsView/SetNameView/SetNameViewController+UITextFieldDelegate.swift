import UIKit

extension SetNameViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        changeNameTextField.resignFirstResponder()
        return true
    }
}
