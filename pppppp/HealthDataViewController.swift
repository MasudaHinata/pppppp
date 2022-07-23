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
        
    }
    
    func readSteps() {
        let distanceType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        
        let calendar = Calendar.current
        let date = Date()
        let endDate = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: date))
        let startDate = calendar.date(byAdding: .day, value: -8, to: calendar.startOfDay(for: date))
        print("日付をとってくるよ",startDate!,endDate!)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY/M/d/(EEEEE) 12:00:00"
        let stepStartData = dateFormatter.string(from: startDate!)
        let stepEndData = dateFormatter.string(from: endDate!)
//        print(stepStartData,stepEndData)
        
        let fromDate = dateFormatter.date(from: stepStartData)!
        let toDate = dateFormatter.date(from: stepEndData)!
        print("あああああああ")
        print(fromDate,toDate)
        print("ああああああああああ")
//        let startDate = DateComponents(year: 2021, month: 6, day: 15)
//        let endDate = DateComponents(year: 2022, month: 7, day: 21)
//        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.date(from: stepStartData)!,end: Calendar.current.date(from: stepEndDate)!)
//        let query = HKStatisticsQuery(quantityType: distanceType,quantitySamplePredicate: predicate,options: [.cumulativeSum]) { query, statistics, error in
//
//            print(statistics!.sumQuantity()!)
//            }
//        myHealthStore.execute(query)
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
