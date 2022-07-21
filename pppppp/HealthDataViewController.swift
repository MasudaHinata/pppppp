import UIKit
import HealthKit
import Combine

class HealthDataViewController: UIViewController {
    
    let myHealthStore = HKHealthStore()
    var cancellables = Set<AnyCancellable>()
    var typeOfBodyMass = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
    var typeOfStepCount = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
    var typeOfHeight = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!
    var weight: Double!
    @IBOutlet var weightTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //healthkit使用の許可
        let typeOfWrite = Set([typeOfBodyMass])
        let typeOfRead = Set([typeOfBodyMass, typeOfStepCount, typeOfHeight])
        myHealthStore.requestAuthorization(toShare: typeOfWrite ,read: typeOfRead,completion: { (success, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            print(success)
        })
        
        readWeight()
        readSteps()
    }
    //体重を取得
    func readWeight() {
        let distanceType = HKObjectType.quantityType(forIdentifier: .bodyMass)!
        let startDate = DateComponents(year: 2021, month: 6, day: 15)
        let endDate = DateComponents(year: 2022, month: 7, day: 21)
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.date(from: startDate)!,end: Calendar.current.date(from: endDate)!)
        let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: [.cumulativeSum]) { query, results,error in
            print(results?.sumQuantity()!)
        }
        myHealthStore.execute(query)
        
//        let endDate = NSSortDescriptor(key: HKSampleSortIdentifierEndDate,ascending: false)
//        let bodyMassQuery = HKSampleQuery(sampleType: typeOfBodyMass, predicate: nil, limit: 0, sortDescriptors: [endDate]) { (query, results, error) in
//
//            print(results!)
//            let result = results?.last as! HKQuantitySample
//            print(result.quantity.doubleValue(for: .gramUnit(with: .kilo)) ,"kg")
//
//
//        }
//        myHealthStore.execute(bodyMassQuery)
    }
    func readSteps() {
        let distanceType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let startDate = DateComponents(year: 2021, month: 6, day: 15)
        let endDate = DateComponents(year: 2022, month: 7, day: 21)
        let predicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.date(from: startDate)!,
            end: Calendar.current.date(from: endDate)!
        )
        let query = HKStatisticsQuery(quantityType: distanceType,quantitySamplePredicate: predicate,options: [.cumulativeSum]) { query, statistics, error in
            
            print(statistics!.sumQuantity()!)
            }
        myHealthStore.execute(query)
    }
    
    //体重を保存
    @IBAction func writeWeightData() {
        guard let inputWeightText = weightTextField.text else { return }
        guard let inputWeight = Double(inputWeightText) else { return }
        
        let task = Task { [weak self] in
            do {
                guard let self = self else { return }
                try await writeWeight(weight: inputWeight)
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
    
    
    func writeWeight(weight: Double) async throws {
        let myWeight = HKQuantity(unit: HKUnit.gramUnit(with: .kilo), doubleValue: weight)
        let myWeightData = HKQuantitySample(type: typeOfBodyMass, quantity: myWeight, start: Date(),end: Date())
        try await self.myHealthStore.save(myWeightData)
    }
    
    
}
