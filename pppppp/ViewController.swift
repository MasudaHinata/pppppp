import UIKit
import HealthKit

class ViewController: UIViewController {
    var myHealthStore : HKHealthStore!
    
    let typeOfWeight = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let types = Set([
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!
        ])
        let healthStore = HKHealthStore()
        healthStore.requestAuthorization(toShare: types, read: types, completion: { success, error in
            print(success)
            print(error)
        })
    }
    
    @IBAction func saveButtonPressed() {
        saveWeight(weight: 100)
    }
    
    @IBAction func readButtonPressed() {
        saveWeight(weight: 100)
    }
    
    func saveWeight(weight: Double) {
        
        
        let myWeight = HKQuantity(unit: HKUnit.gram(), doubleValue: weight)
        
        let myWeightData = HKQuantitySample(type: typeOfWeight, quantity: myWeight, start: Date(), end: Date())
        
        // データの保存.
        self.myHealthStore.save(myWeightData, withCompletion: {
            (success: Bool, error: Error!) in
            if success {
                NSLog("Success!")
            } else {
                print("Error!")
            }
        })
    }
    
    func read() -> Double? {
        var bodyMasskg: Double?
        let query = HKSampleQuery(sampleType: typeOfWeight, predicate: nil, limit: 1, sortDescriptors: nil) { (query, results, error) in
            if let result = results?.first as? HKQuantitySample {
                bodyMasskg = result.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            }
        }
        myHealthStore.execute(query)
        return bodyMasskg
    }
}


