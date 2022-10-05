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
        guard let inputWeightText = weightTextField.text else { return }
        guard let inputWeight = Double(inputWeightText) else {
            ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "体重を入力してください", handler: { _ in })
            return
        }
        
        guard let inputWeightGoalText = weightGoalTextField.text else { return }
        guard let inputWeightGoal = Double(inputWeightGoalText) else {
            ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "目標体重を入力してください", handler: { _ in })
            return
            
        }
        
        UserDefaults.standard.set(inputWeightGoal, forKey: "weightGoal")
        
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                try await HealthKit_ScoreringManager.shared.writeWeight(weight: inputWeight)
                ShowAlertHelper.okAlert(vc: self, title: "完了", message: "体重と目標体重を記録しました", handler: { _ in })
            }
            catch {
                print("SetGoalWeightViewDid error:", error.localizedDescription)
                ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)", handler: { _ in })
            }
        }
        self.cancellables.insert(.init { task.cancel() })
        
        let secondVC = StoryboardScene.Main.initialScene.instantiate()
        self.showDetailViewController(secondVC, sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(true, forKey: "initialScreen")
        
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
