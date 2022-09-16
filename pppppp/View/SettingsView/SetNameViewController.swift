import UIKit
import Combine

class SetNameViewController: UIViewController {
    
    var changename = ""
    var cancellables = Set<AnyCancellable>()
    
    @IBOutlet var changeNameTextField: UITextField! {
        didSet {
            changeNameTextField.layer.cornerRadius = 8
            changeNameTextField.clipsToBounds = true
            changeNameTextField.layer.cornerCurve = .continuous
        }
    }
    
    @IBOutlet var changeNameButtonLayout: UIButton! {
        didSet {
            changeNameButtonLayout.layer.cornerRadius = 24
            changeNameButtonLayout.clipsToBounds = true
            changeNameButtonLayout.layer.cornerCurve = .continuous
            var configuration = UIButton.Configuration.filled()
            configuration.title = "Set your name"
            configuration.baseBackgroundColor = .init(hex: "92B2D3")
            configuration.imagePlacement = .trailing
            configuration.showsActivityIndicator = false
            configuration.imagePadding = 24
            changeNameButtonLayout.configuration = configuration
        }
    }
    
    @IBAction func changeName() {
        let task = Task {
            do {
                changename = changeNameTextField.text!
                if changename != "" {
                    try await FirebaseClient.shared.putNameFirestore(name: changename)
                    let alert = UIAlertController(title: "完了", message: "名前を設定しました", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let secondVC = storyboard.instantiateViewController(identifier: "TabBarViewController")
                        self.showDetailViewController(secondVC, sender: self)
                    }
                    alert.addAction(ok)
                    present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "エラー", message: "名前を入力してください", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                    }
                    alert.addAction(ok)
                    present(alert, animated: true, completion: nil)
                }
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
        self.changeNameTextField.delegate = self
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}

//MARK: - UITextFieldDelegate
extension SetNameViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        changeNameTextField.resignFirstResponder()
        return true
    }
}