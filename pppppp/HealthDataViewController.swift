import Combine
import UIKit
import HealthKit

class HealthDataViewController: UIViewController {
    
    let myHealthStore = HKHealthStore()
    var cancellables = Set<AnyCancellable>()
    var typeOfBodyMass = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
    var typeOfStepCount = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
    var typeOfHeight = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!
    let calendar = Calendar.current
    let date = Date()
    var weight: Double!
    var averageSteps = Int()
    var yesterdaySteps = Int()

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
        
        let task = Task {
            do {
                try await readAverageSteps()
                try await readYesterdaySteps()
                try await readWeight()
            }
            catch {
                print("error")
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    
    //体重を取得
    func readWeight() async throws {
        let endDate = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: date))
        let startDate = calendar.date(byAdding: .day, value: -31, to: calendar.startOfDay(for: date))
        
        //TODO: 日付の指定をする(HKSampleQueryDescriptor日付指定できる？)
        let descriptor = HKSampleQueryDescriptor(predicates:[.quantitySample(type: typeOfBodyMass)], sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)], limit: nil)
        let results = try await descriptor.result(for: myHealthStore)
        let doubleValues = results.map {
            $0.quantity.doubleValue(for: .gramUnit(with: .kilo))
        }
        print(doubleValues)
    }
    //TODO: funcひとつにまとめる
    //１ヶ月平均の歩数を取得
    func readAverageSteps() async throws {
        //TODO: やっぱりGMT直す
        let endDateAve = calendar.date(byAdding: .day, value: -2, to: calendar.startOfDay(for: date))
        let startDateAve = calendar.date(byAdding: .day, value: -32, to: calendar.startOfDay(for: date))
        let periodAve = HKQuery.predicateForSamples(withStart: startDateAve, end: endDateAve)
        let stepsTodayAve = HKSamplePredicate.quantitySample(type: typeOfStepCount, predicate: periodAve)
        let sumOfStepsQueryAve = HKStatisticsQueryDescriptor(predicate: stepsTodayAve, options: .cumulativeSum)
        print(startDateAve!,endDateAve!)
        //FIXME: ERRORHANDLING
        let stepCount = try await sumOfStepsQueryAve.result(for: myHealthStore)?.sumQuantity()?.doubleValue(for: HKUnit.count())
        print(stepCount!)
        averageSteps = Int(stepCount! / 31)
        print(averageSteps)
    }
    //昨日の歩数を取得
    func readYesterdaySteps() async throws {
        //TODO: やっぱりGMT直す
        let endDate = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: date))
        let startDate = calendar.date(byAdding: .day, value: -2, to: calendar.startOfDay(for: date))
        let period = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let stepsToday = HKSamplePredicate.quantitySample(type: typeOfStepCount, predicate: period)
        let sumOfStepsQuery = HKStatisticsQueryDescriptor(predicate: stepsToday, options: .cumulativeSum)
        print(startDate!,endDate!)
        //FIXME: ERRORHANDLING
        let stepCount = try await sumOfStepsQuery.result(for: myHealthStore)?.sumQuantity()?.doubleValue(for: HKUnit.count())
        print(stepCount!)
        yesterdaySteps = Int(stepCount!)
        print(yesterdaySteps)
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
