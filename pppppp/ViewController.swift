import UIKit
import HealthKit


class ViewController: UIViewController {
    
    var myHealthStore = HKHealthStore()
    
    let typeOfWeight = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!

    override func viewDidLoad() {
        super.viewDidLoad()
       
        titleTextField.text = String(read())
        
        //ユーザーの許可を得る(healthkit使用)
        let types = Set([
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!
        ])
        let healthStore = HKHealthStore()
        healthStore.requestAuthorization(toShare: types, read: types, completion: { success, error in
            print(success)
            print(error)
        })
        
        titleTextField.delegate = self
        
    }
    
    @IBOutlet var titleTextField: UITextField!
    
    func saveWeight(weight: Double) {
        
        let weight = HKQuantity(unit: HKUnit.gramUnit(with: .kilo), doubleValue: weight)
        
        let WeightData = HKQuantitySample(type: typeOfWeight, quantity: weight, start: Date(), end: Date())
        
        // データの保存.
        self.myHealthStore.save(WeightData, withCompletion: {
            (success: Bool, error: Error!) in
            if success {
                NSLog("Success!")
            } else {
                print("error")
            }
        })
    }
    
    func read() -> Double {
        var bodyMasskg: Double = 0.0
        let query = HKSampleQuery(sampleType: typeOfWeight, predicate: nil, limit: 1, sortDescriptors: nil) { (query, results, error) in
            if let result = results?.first as? HKQuantitySample {
                bodyMasskg = result.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            }
        }
        myHealthStore.execute(query)
        return bodyMasskg
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ titleTextField: UITextField) -> Bool {
        guard let weightText = titleTextField.text else { return true}
        saveWeight(weight: Double(weightText)!)
        print(weightText)
        return true
    }
}


