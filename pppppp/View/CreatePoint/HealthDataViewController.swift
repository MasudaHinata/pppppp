import Combine
import UIKit
import HealthKit

class HealthDataViewController: UIViewController{
    
    var cancellables = Set<AnyCancellable>()
    let calendar = Calendar.current
    
    let myHealthStore = Scorering.shared.myHealthStore
    var typeOfBodyMass = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
    var typeOfStepCount = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
    var typeOfHeight = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!
    
    var exerciseTypePicker = UIPickerView()
    let exerciseTypeList = ["筋トレ", "運動を選択してください", "ランニング", "テニス"]
    
    @IBOutlet var selectExerciseTextField: UITextField! {
        didSet {
            selectExerciseTextField.layer.cornerRadius = 16
            selectExerciseTextField.clipsToBounds = true
            selectExerciseTextField.layer.cornerCurve = .continuous
        }
    }
    
    @IBOutlet var exerciseTimeTextField: UITextField! {
        didSet {
            exerciseTimeTextField.layer.cornerRadius = 16
            exerciseTimeTextField.clipsToBounds = true
            exerciseTimeTextField.layer.cornerCurve = .continuous
        }
    }
    
    @IBOutlet var enterExerciseBackgroundView: UIView! {
        didSet {
            enterExerciseBackgroundView.layer.cornerRadius = 36
            enterExerciseBackgroundView.clipsToBounds = true
            enterExerciseBackgroundView.layer.cornerCurve = .continuous
            enterExerciseBackgroundView.backgroundColor = UIColor.init(hex: "443FA3")
        }
    }
    
    @IBOutlet var weightTextField: UITextField! {
        didSet {
            weightTextField.layer.cornerRadius = 24
            weightTextField.clipsToBounds = true
            weightTextField.layer.cornerCurve = .continuous
        }
    }
    
    @IBOutlet var enterWeightbackgroundView: UIView! {
        didSet {
            enterWeightbackgroundView.layer.cornerRadius = 36
            enterWeightbackgroundView.clipsToBounds = true
            enterWeightbackgroundView.layer.cornerCurve = .continuous
            enterWeightbackgroundView.backgroundColor = UIColor.init(hex: "443FA3")
        }
    }
    
    @IBOutlet var writeWeightDataLayout: UIButton! {
        didSet {
            writeWeightDataLayout.layer.cornerRadius = 16
            writeWeightDataLayout.clipsToBounds = true
            writeWeightDataLayout.layer.cornerCurve = .continuous
        }
    }
    
    @IBAction func writeWeightData() {
        guard let inputWeightText = weightTextField.text else { return }
        guard let inputWeight = Double(inputWeightText) else { return }
        
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                try await Scorering.shared.writeWeight(weight: inputWeight)
                let alart = UIAlertController(title: "完了", message: "体重を記録しました", preferredStyle: .alert)
                let action = UIAlertAction(title: "ok", style: .default)
                alart.addAction(action)
                self.present(alart, animated: true)
            }
            catch {
                print("HealthData writeWeight error:", error.localizedDescription)
                if error.localizedDescription == "Not authorized" {
                    let alert = UIAlertController(title: "エラー", message: "設定からHealthKitの許可をオンにしてください", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(action)
                    self.present(alert, animated: true)
                } else {
                    let alert = UIAlertController(title: "エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(action)
                    self.present(alert, animated: true)
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
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        
        exerciseTypePicker.delegate = self
        exerciseTypePicker.dataSource = self
        exerciseTypePicker.selectRow(1, inComponent: 0, animated: false)
        selectExerciseTextField.inputView = exerciseTypePicker
        selectExerciseTextField.inputAccessoryView = toolbar
        
//        let task = Task {
//            do {
//                try await Scorering.shared.readWeight()
//            }
//            catch {
//                print("HealthDataViewContr ViewDid error:", error.localizedDescription)
//            }
//        }
//        cancellables.insert(.init { task.cancel() })
    }
    
    @objc func done() {
        selectExerciseTextField.endEditing(true)
        selectExerciseTextField.text = "\(exerciseTypeList[exerciseTypePicker.selectedRow(inComponent: 0)])"
       }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
