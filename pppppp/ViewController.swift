import UIKit
import HealthKit
import Firebase

class ViewController: UIViewController {
    
    var me: AppUser!
    
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var label: UILabel!
    
    @IBAction func SettingButton() {
        
    }

    
    let db = Firestore.firestore()
    
    var myHealthStore = HKHealthStore()
    var typeOfBodyMass = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
    var bodyMass: Double = 0 {
        didSet {
            DispatchQueue.main.async {
                self.titleTextField.text = String(self.bodyMass)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let types = Set([typeOfBodyMass])
        let healthStore = HKHealthStore()
        healthStore.requestAuthorization(toShare: types, read: types, completion: { success, error in
            print(success)
            print(error)
        })
        
        titleTextField?.delegate = self
        read()

        //label.text = saveData.string(forKey: "key")

        
    }
    
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
        if let user = Auth.auth().currentUser {
            let dataStore = Firestore.firestore()
                    dataStore.collection("weight").addDocument(data: [
                        "text": weight,
                        "name": user.displayName,
                        "sender_id": UUID(),
                        "date": Date()
                    ]) { err in
                        DispatchQueue.main.async {
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                              return
                            }
                        }
                    }
        }
        
        
    }
    
    func read() {
        let query = HKSampleQuery(sampleType: typeOfBodyMass, predicate: nil, limit: 1, sortDescriptors: nil) { (query, results, error) in
            if let results = results as? [HKQuantitySample] {
                print(results)
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
