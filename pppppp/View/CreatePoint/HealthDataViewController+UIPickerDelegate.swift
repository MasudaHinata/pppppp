import UIKit

extension HealthDataViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    //UIPickerViewの列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //UIPickerViewの選択肢の数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return exerciseTypeList.count
    }
    
    //UIPickerViewの要素をセット
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return exerciseTypeList[row]
    }
    
    //UIPickerViewの要素が選択されたときの処理
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectExerciseTextField.text = exerciseTypeList[row]
    }
}
