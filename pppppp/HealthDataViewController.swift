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
    var stepPoint = Int()
    @IBOutlet var weightTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
        
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
        
        //        readWeight()
        
        let task = Task { [weak self] in
            do {
                try await readSteps()
            }
            catch {
                //TODO: ERROR Handling
                print("error")
            }
        }
        
    }
    
    //体重を取得
    func readWeight() {
        let endDate = NSSortDescriptor(key: HKSampleSortIdentifierEndDate,ascending: false)
        let bodyMassQuery = HKSampleQuery(sampleType: typeOfBodyMass,predicate: nil,limit: 0,sortDescriptors: [endDate]) { (query, results, error) in
            
            let myRecentSample = results as? HKQuantitySample
            let myResentWeighingData = myRecentSample!.quantity.doubleValue(for: .gramUnit(with: .kilo))
            print(myResentWeighingData)
        }
        myHealthStore.execute(bodyMassQuery)
    }
    
    //歩数を取得
    func readSteps() async throws {
        let calendar = Calendar.current
        let date = Date()
        let endDate = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: date))
        let startDate = calendar.date(byAdding: .day, value: -31, to: calendar.startOfDay(for: date))
        let today = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let stepsToday = HKSamplePredicate.quantitySample(type: typeOfStepCount, predicate:today)
        let sumOfStepsQuery = HKStatisticsQueryDescriptor(predicate: stepsToday, options: .cumulativeSum)
        
        let stepCount = try await sumOfStepsQuery.result(for: myHealthStore)?.sumQuantity()?.doubleValue(for: HKUnit.count())
        
        print(stepCount!)
        let averageSteps = stepCount! / 31
        print(averageSteps)
        self.stepPoint = Int(Float(averageSteps))
        print(self.stepPoint)
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
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
