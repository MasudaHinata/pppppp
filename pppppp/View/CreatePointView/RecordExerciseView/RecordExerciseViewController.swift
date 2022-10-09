import Combine
import UIKit

class RecordExerciseViewController: UIViewController, FirebasePutPointDelegate {
    
    var cancellables = Set<AnyCancellable>()
    var exerciseTypePicker = UIPickerView()
    var exerciseTimePicker = UIPickerView()
    let exerciseTypeList = ["軽いジョギング", "ランニング", "運動を選択してください", "筋トレ(軽・中等度)", "筋トレ(強等度)", "テニス(ダブルス)", "テニス(シングルス)", "水泳(ゆっくりとした背泳ぎ・平泳ぎ)", "水泳(クロール・普通の速さ)", "水泳(クロール・速い)", "野球"]
    let exerciseTimeList: [Int] = Array(0...120)
    
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
    
    @IBAction func recordExerciseButton() {
        if selectExerciseTextField.text == "" || selectExerciseTextField.text == "運動を選択してください" {
            ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "運動を選択してください")
        } else if exerciseTimeTextField.text == "" || exerciseTimeTextField.text == "0" {
            ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "時間を選択してください")
        } else {
            let task = Task { [weak self] in
                guard let self = self else { return }
                do {
                    try await HealthKit_ScoreringManager.shared.createExercisePoint(exercisesName: selectExerciseTextField.text!, time: Float(exerciseTimeTextField.text!)!)
                    exerciseTimeTextField.text = ""
                    selectExerciseTextField.text = ""
                }
                catch {
                    print("RecordExerciseView recordExerciseButton error:", error.localizedDescription)
                    if error.localizedDescription == "Not authorized" {
                        ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "設定からHealthKitの許可をオンにしてください")
                    } else {
                        ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)")
                    }
                }
            }
            cancellables.insert(.init { task.cancel() })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseClient.shared.putPointDelegate = self
        self.view.layer.cornerRadius = 48
        self.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
        
        exerciseTypePicker.tag = 0
        exerciseTimePicker.tag = 1
        let exerciseTypeToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let exerciseTypeSpacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let exerciseTypeDoneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(selectExerciseDone))
        exerciseTypeToolbar.setItems([exerciseTypeSpacelItem, exerciseTypeDoneItem], animated: true)
        exerciseTypePicker.delegate = self
        exerciseTypePicker.dataSource = self
        exerciseTypePicker.selectRow(2, inComponent: 0, animated: false)
        selectExerciseTextField.inputView = exerciseTypePicker
        selectExerciseTextField.inputAccessoryView = exerciseTypeToolbar
        
        let exerciseTimeToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let exerciseTimeSpacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let exerciseTimeDoneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(exerciseTimeDone))
        exerciseTimeToolbar.setItems([exerciseTimeSpacelItem, exerciseTimeDoneItem], animated: true)
        exerciseTimePicker.delegate = self
        exerciseTimePicker.dataSource = self
        exerciseTimePicker.selectRow(0, inComponent: 0, animated: false)
        exerciseTimeTextField.inputView = exerciseTimePicker
        exerciseTimeTextField.inputAccessoryView = exerciseTimeToolbar
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
    
    //MARK: - Setting Delegate
    func putPointForFirestore(point: Int, activity: String) {
        let alert = UIAlertController(title: "ポイントを獲得しました", message: "\(activity): \(point)pt", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    func notGetPoint() {
        let alert = UIAlertController(title: "今日の獲得ポイントは0ptです", message: "頑張りましょう", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
