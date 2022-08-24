import Combine
import UIKit
import HealthKit

class HealthDataViewController: UIViewController {
    
    var cancellables = Set<AnyCancellable>()
    let myHealthStore = Scorering.shared.myHealthStore
    var typeOfBodyMass = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
    var typeOfStepCount = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
    var typeOfHeight = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!
    let UD = UserDefaults.standard
    let calendar = Calendar.current
    
    @IBOutlet var weightTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weightTextField.layer.cornerRadius = 24
        weightTextField.clipsToBounds = true
        weightTextField.layer.cornerCurve = .continuous
        
        Scorering.shared.getPermissionHealthKit()
        
        let task = Task {
            do {
                try await Scorering.shared.createStepPoint()
                try await Scorering.shared.createStepPoint()
                try await Scorering.shared.readWeight()
            }
            catch {
                print("HealthData error")
            }
        }
        cancellables.insert(.init { task.cancel() })
        
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
    }
    //体重を保存
    @IBAction func writeWeightData() {
        guard let inputWeightText = weightTextField.text else { return }
        guard let inputWeight = Double(inputWeightText) else { return }

        let task = Task { [weak self] in
            do {
                guard let self = self else { return }
                try await Scorering.shared.writeWeight(weight: inputWeight)
                let alart = UIAlertController(title: "記録", message: "体重を記録しました", preferredStyle: .alert)
                let action = UIAlertAction(title: "ok", style: .default)
                alart.addAction(action)
                self.present(alart, animated: true)
            }
            catch {
                print("writeWeight error")
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
