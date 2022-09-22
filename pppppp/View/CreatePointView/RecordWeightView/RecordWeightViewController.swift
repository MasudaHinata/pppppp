import UIKit
import Combine
import HealthKit

class RecordWeightViewController: UIViewController {
    
    var cancellables = Set<AnyCancellable>()
    
    let myHealthStore = Scorering.shared.myHealthStore
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
        guard let inputWeight = Double(inputWeightText) else { return }
        
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                try await Scorering.shared.writeWeight(weight: inputWeight)
                ShowAlertHelper.okAlert(vc: self, title: "完了", message: "体重を記録しました", handler: { _ in })
                weightTextField.text = ""
            }
            catch {
                print("RecordExerciseView writeWeight error:", error.localizedDescription)
                if error.localizedDescription == "Not authorized" {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "設定からHealthKitの許可をオンにしてください", handler: { _ in })
                } else {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)", handler: { _ in })
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
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
