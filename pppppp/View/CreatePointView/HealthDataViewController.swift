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
    var exerciseTimePicker = UIPickerView()
    let exerciseTypeList = ["軽いジョギング", "ランニング", "運動を選択してください", "筋トレ(軽・中等度)", "筋トレ(強等度)", "サイクリング", "テニス(ダブルス)", "テニス(シングルス)", "水泳(ゆっくりとした背泳ぎ・平泳ぎ)", "水泳(クロール・普通の速さ)", "水泳(クロール・速い)", "野球"]
    
    let exerciseTimeList: [Int] = Array(0...120)
    
    @IBOutlet var enterExerciseBackgroundView: UIView! {
        didSet {
            enterExerciseBackgroundView.layer.cornerRadius = 36
            enterExerciseBackgroundView.clipsToBounds = true
            enterExerciseBackgroundView.layer.cornerCurve = .continuous
            enterExerciseBackgroundView.backgroundColor = UIColor.init(hex: "443FA3")
        }
    }
    
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
    
    @IBOutlet var saveExerciseButtonLayout: UIButton! {
        didSet {
            saveExerciseButtonLayout.layer.cornerRadius = 16
            saveExerciseButtonLayout.clipsToBounds = true
            saveExerciseButtonLayout.layer.cornerCurve = .continuous
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
    
    @IBAction func recordExerciseButton() {
        if selectExerciseTextField.text != "", selectExerciseTextField.text != "運動を選択してください", exerciseTimeTextField.text != "", exerciseTimeTextField.text != "0" {
            Scorering.shared.createExercisePoint(exercise: selectExerciseTextField.text! , time: Float(exerciseTimeTextField.text!)!)
        } else if selectExerciseTextField.text == "" || selectExerciseTextField.text == "運動を選択してください" {
            ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "運動を選択してください", handler: { (_) in })
        } else if exerciseTimeTextField.text == "" || exerciseTimeTextField.text == "0" {
            ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "時間を選択してください", handler: { (_) in })
        }
    }
    
    @IBAction func writeWeightDataButton() {
        guard let inputWeightText = weightTextField.text else { return }
        guard let inputWeight = Double(inputWeightText) else { return }
        
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                try await Scorering.shared.writeWeight(weight: inputWeight)
//                ShowAlertHelper.okAlert(vc: self, title: "完了", message: "体重を記録しました", handler: { (_) in })
            }
            catch {
                print("HealthData writeWeight error:", error.localizedDescription)
                if error.localizedDescription == "Not authorized" {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "設定からHealthKitの許可をオンにしてください", handler: { (_) in })
                } else {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)", handler: { (_) in })
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

//        exerciseTypePicker.tag = 0
//        exerciseTimePicker.tag = 1
//
//        let exerciseTypeToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
//        let exerciseTypeSpacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
//        let exerciseTypeDoneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(selectExerciseDone))
//        exerciseTypeToolbar.setItems([exerciseTypeSpacelItem, exerciseTypeDoneItem], animated: true)
//        exerciseTypePicker.delegate = self
//        exerciseTypePicker.dataSource = self
//        exerciseTypePicker.selectRow(2, inComponent: 0, animated: false)
//        selectExerciseTextField.inputView = exerciseTypePicker
//        selectExerciseTextField.inputAccessoryView = exerciseTypeToolbar
//
//        let exerciseTimeToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
//        let exerciseTimeSpacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
//        let exerciseTimeDoneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(exerciseTimeDone))
//        exerciseTimeToolbar.setItems([exerciseTimeSpacelItem, exerciseTimeDoneItem], animated: true)
//        exerciseTimePicker.delegate = self
//        exerciseTimePicker.dataSource = self
//        exerciseTimePicker.selectRow(0, inComponent: 0, animated: false)
//        exerciseTimeTextField.inputView = exerciseTimePicker
//        exerciseTimeTextField.inputAccessoryView = exerciseTimeToolbar
        
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
    
    @objc func selectExerciseDone() {
        selectExerciseTextField.endEditing(true)
        selectExerciseTextField.text = "\(exerciseTypeList[exerciseTypePicker.selectedRow(inComponent: 0)])"
    }
    
    @objc func exerciseTimeDone() {
        exerciseTimeTextField.endEditing(true)
        exerciseTimeTextField.text = "\(exerciseTimeList[exerciseTimePicker.selectedRow(inComponent: 0)])"
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
