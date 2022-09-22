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
            var configuration = UIButton.Configuration.filled()
            configuration.title = "Set your name"
            configuration.baseBackgroundColor = Asset.Colors.lightBlue00.color
            configuration.showsActivityIndicator = false
            changeNameButtonLayout.configuration = configuration
        }
    }
    
    @IBAction func changeName() {
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                changename = changeNameTextField.text!
                if changename != "" {
                    try await FirebaseClient.shared.putNameFirestore(name: changename)
                    ShowAlertHelper.okAlert(vc: self, title: "完了", message: "名前を設定しました", handler: { _ in
                        let secondVC = StoryboardScene.Main.initialScene.instantiate()
                        self.showDetailViewController(secondVC, sender: self)
                    })
                } else {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "名前を入力してください", handler: { _ in })
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
