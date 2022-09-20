import UIKit

extension HealthDataViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    //UIPickerViewの列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //UIPickerViewの選択肢の数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 0:
            return exerciseTypeList.count
        case 1:
            return exerciseTimeList.count
        default:
            return 0
        }
    }
    
    //UIPickerViewの要素をセット
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 0:
            return exerciseTypeList[row]
        case 1:
            return String(exerciseTimeList[row])
        default:
            return "error"
        }
    }
    
    //UIPickerViewの要素が選択されたときの処理
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 0:
            selectExerciseTextField.text = exerciseTypeList[row]
        case 1:
            exerciseTimeTextField.text = String(exerciseTimeList[row])
        default:
            print("error")
        }
    }
}
