import UIKit
import Combine
import HealthKit

class RecordWeightViewController: UIViewController {
    
    var cancellables = Set<AnyCancellable>()
    
    let myHealthStore = HealthKitScoreringManager.shared.myHealthStore
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
                try await HealthKitScoreringManager.shared.writeWeight(weight: inputWeight)

                let userID = try await FirebaseClient.shared.getUserUUID()
                let userData: [UserData] = try await FirebaseClient.shared.getUserDataFromId(userId: userID)
                guard let goalWeight = userData.last?.weightGoal else {
                    let settingGoalWeightVC = SettingGoalWeightHostingController(viewModel: SettingGoalWeightViewModel())
                    settingGoalWeightVC.modalPresentationStyle = .fullScreen
                    self.showDetailViewController(settingGoalWeightVC, sender: self)
                    return
                }
                let checkPoint = try await HealthKitScoreringManager.shared.createWeightPoint(weightGoal: goalWeight, weight: inputWeight)
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
