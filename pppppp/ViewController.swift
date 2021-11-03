import UIKit
import HealthKit
import Firebase


class ViewController: UIViewController {
    
    var myHealthStore = HKHealthStore()
    var typeOfBodyMass = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
    var bodyMass: Double = 0 {
        didSet {
            DispatchQueue.main.async {
                self.titleTextField?.text = String(self.bodyMass)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
       //ユーザーの許可を得る(healthkit使用)
        let types = Set([typeOfBodyMass])
        let healthStore = HKHealthStore()
        healthStore.requestAuthorization(toShare: types, read: types, completion: { success, error in
            print(success)
            print(error)
        })
        
        titleTextField?.delegate = self
        read()

        label.text = saveData.string(forKey: "key")

        
    }
    
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var label: UILabel!
    let saveData: UserDefaults = UserDefaults.standard

    
    func saveWeight(weight: Double) {
        
        let weight = HKQuantity(unit: HKUnit.gramUnit(with: .kilo), doubleValue: weight)
        
        let WeightData = HKQuantitySample(type: typeOfBodyMass, quantity: weight, start: Date(), end: Date())
        
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
    
    func read() {
        let query = HKSampleQuery(sampleType: typeOfBodyMass, predicate: nil, limit: 1, sortDescriptors: nil) { (query, results, error) in
            if let result = results?.first as? HKQuantitySample {
                self.bodyMass = result.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            }
        }
        myHealthStore.execute(query)
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
