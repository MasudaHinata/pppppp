import UIKit
import Combine

class SetGoalWeightViewController: UIViewController {
    
    var cancellables = Set<AnyCancellable>()
    
    @IBOutlet var weightTextField: UITextField! {
        didSet {
            weightTextField.layer.cornerRadius = 8
            weightTextField.clipsToBounds = true
            weightTextField.layer.cornerCurve = .continuous
        }
    }
    
    @IBOutlet var weightGoalTextField: UITextField! {
        didSet {
            weightGoalTextField.layer.cornerRadius = 8
            weightGoalTextField.clipsToBounds = true
            weightGoalTextField.layer.cornerCurve = .continuous
        }
    }
    
    @IBOutlet var saveWeightGoalButtonLayout: UIButton! {
        didSet {
            var configuration = UIButton.Configuration.filled()
            configuration.title = "Seve your weight & goal"
            configuration.baseBackgroundColor = Asset.Colors.lightBlue00.color
            configuration.showsActivityIndicator = false
            saveWeightGoalButtonLayout.configuration = configuration
        }
    }
    
    @IBAction func saveWeightGoalButton(_ sender: Any) {
        guard let inputWeightGoalText = weightGoalTextField.text else { return }
        guard let inputWeightGoal = Double(inputWeightGoalText) else {
            ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "目標体重を入力してください")
            return
        }

        guard let inputWeightText = weightTextField.text else { return }
        if inputWeightText != "" {
            let task = Task { [weak self] in
                guard let self = self else { return }
                do {
                    try await HealthKit_ScoreringManager.shared.writeWeight(weight: Double(inputWeightText) ?? 0)
                }
                catch {
                    print("SetGoalWeightViewDid error:", error.localizedDescription)
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)")
                }
            }
            self.cancellables.insert(.init { task.cancel() })
        }

        UserDefaults.standard.set(inputWeightGoal, forKey: "weightGoal")

        ShowAlertHelper.okAlert(vc: self, title: "完了", message: "記録しました") { _ in
            let mainVC = StoryboardScene.Main.initialScene.instantiate()
            self.showDetailViewController(mainVC, sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
