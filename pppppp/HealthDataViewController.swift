import Combine
import UIKit
import HealthKit

import Firebase
import FirebaseFirestore

class HealthDataViewController: UIViewController {
    
    var cancellables = Set<AnyCancellable>()
    let myHealthStore = Scorering.shared.myHealthStore
    var typeOfBodyMass = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
    var typeOfStepCount = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
    var typeOfHeight = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!
    
    @IBOutlet var weightTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Scorering.shared.getPermissionHealthKit()
        
        let task = Task {
            do {
                try await Scorering.shared.createStepPoint()
                try await Scorering.shared.createStepPoint()
                try await Scorering.shared.readWeight()
            }
            catch {
                print("error")
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
                print("error")
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    //自己評価
    @IBAction func goodButton(){
        let task = Task {
            do {
                try await Scorering.shared.getUntilNowPoint()
                let untilNowPoint = Scorering.shared.untilNowPoint
                let sanitasPoints = untilNowPoint + 15
                try await Scorering.shared.firebasePutData(point: sanitasPoints)
            }
            catch {
                //TODO: ERROR Handling
                print("error")
            }
        }
    }
    @IBAction func normalButton(){
        let task = Task {
            do {
                try await Scorering.shared.getUntilNowPoint()
                let untilNowPoint = Scorering.shared.untilNowPoint
                let sanitasPoints = untilNowPoint + 10
                try await Scorering.shared.firebasePutData(point: sanitasPoints)
            }
            catch {
                //TODO: ERROR Handling
                print("error")
            }
        }
    }
    @IBAction func badButton(){
        let task = Task {
            do {
                try await Scorering.shared.getUntilNowPoint()
                let untilNowPoint = Scorering.shared.untilNowPoint
                let sanitasPoints = untilNowPoint + 5
                try await Scorering.shared.firebasePutData(point: sanitasPoints)
                
            }
            catch {
                //TODO: ERROR Handling
                print("error")
            }
        }
    }

    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
