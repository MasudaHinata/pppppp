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
    let UD = UserDefaults.standard
    let calendar = Calendar.current
    let date = Date()
    
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

    @IBAction func goSelfButton(){
        let now_day = Date(timeIntervalSinceNow: 60 * 60 * 9)
        var judge = Bool()
        if UD.object(forKey: "key") != nil {
            let past_day = UD.object(forKey: "key") as! Date
            let now = calendar.component(.day, from: now_day)
            let past = calendar.component(.day, from: past_day)
            print(UD.object(forKey: "key")!)
            print(now)
            if now != past {
                judge = true
            }
            else {
                judge = false
            }
        } else {
            judge = true
            UD.set(now_day, forKey: "key")
            print(UD.object(forKey: "key")!)
        }
        if judge == true {
            judge = false
            print("日付変わったから自己評価する")
            UD.set(now_day, forKey: "key")
            print(UD.object(forKey: "key")!)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let secondVC = storyboard.instantiateViewController(identifier: "SelfAssessmentViewController")
            self.showDetailViewController(secondVC, sender: self)
        }
        else {
            print("今日はもう自己評価した")
            let alart = UIAlertController(title: "エラー", message: "今日の自己評価は完了しています", preferredStyle: .alert)
            let action = UIAlertAction(title: "ok", style: .default)
            alart.addAction(action)
            self.present(alart, animated: true)
        }
    }

    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
