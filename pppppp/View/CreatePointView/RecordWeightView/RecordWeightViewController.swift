import UIKit
import Combine
import HealthKit

class RecordWeightViewController: UIViewController {
    
    var cancellables = Set<AnyCancellable>()
    
    let myHealthStore = HealthKit_ScoreringManager.shared.myHealthStore
    var typeOfBodyMass = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
    var typeOfStepCount = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
    var typeOfHeight = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!
    
    @IBOutlet var weightTextField: UITextField! {
        didSet {
            weightTextField.layer.cornerRadius = 24
            weightTextField.clipsToBounds = true
            weightTextField.layer.cornerCurve = .continuous
        }
    }
    
    @IBOutlet var writeWeightDataButtonLayout: UIButton! {
        didSet {
            writeWeightDataButtonLayout.layer.cornerRadius = 16
            writeWeightDataButtonLayout.clipsToBounds = true
            writeWeightDataButtonLayout.layer.cornerCurve = .continuous
        }
    }
    
    @IBAction func writeWeightDataButton() {
        guard let inputWeightText = weightTextField.text else { return }
        guard let inputWeight = Double(inputWeightText) else {
            ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "体重を入力してください")
            return
        }
        
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                try await HealthKit_ScoreringManager.shared.writeWeight(weight: inputWeight)

                guard let goalWeight = UserDefaults.standard.object(forKey: "weightGoal") else {
                    let setGoalWeightVC = StoryboardScene.SetGoalWeightView.initialScene.instantiate()
                    self.showDetailViewController(setGoalWeightVC, sender: self)
                    return
                }
                let checkPoint = try await HealthKit_ScoreringManager.shared.createWeightPoint(weightGoal: goalWeight as! Double, weight: inputWeight)
                if checkPoint == [] {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "過去2s週間の体重データがないためポイントを作成できませんでした")
                }
                
                ShowAlertHelper.okAlert(vc: self, title: "完了", message: "体重を記録しました")
                weightTextField.text = ""
            }
            catch {
                print("RecordExerciseView writeWeight error:", error.localizedDescription)
                if error.localizedDescription == "Not authorized" {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "設定からHealthKitの許可をオンにしてください")
                } else {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)")
                }
            }
        }
        cancellables.insert(.init { task.cancel() })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layer.cornerRadius = 48
        self.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
