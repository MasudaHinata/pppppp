import Foundation
import HealthKit

let myHealthStore = HKHealthStore()
var typeOfBodyMass = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
var typeOfStepCount = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
var typeOfHeight = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!

final class Scorering {
    static let shared = Scorering()
    private init() {}
    
    let myHealthStore = HKHealthStore()
    let calendar = Calendar.current
    let date = Date()
    var weight: Double!
    var sanitasPoint = Int()
    let UD = UserDefaults.standard
    
    func getPermissionHealthKit() {
        let typeOfRead = Set([typeOfStepCount])
        myHealthStore.requestAuthorization(toShare: nil, read: typeOfRead) { (success, error) in
            if let error = error {
                print("Scorering getPermission error:", error.localizedDescription)
                return
            }
        }
    }
    
    func createStepPoint() async throws {
        var judge = Bool()
        if UD.object(forKey: "today") != nil {
            let past_day = UD.object(forKey: "today") as! Date
            let now = calendar.component(.day, from: Date())
            let past = calendar.component(.day, from: past_day)
            if now != past {
                judge = true
            }
            else {
                judge = false
            }
        } else {
            judge = true
            UD.set(Date(), forKey: "today")
        }
        if judge == true {
            judge = false
            getPermissionHealthKit()
            
            let endDateAve = calendar.date(byAdding: .day, value: -2, to: calendar.startOfDay(for: date))
            let startDateAve = calendar.date(byAdding: .day, value: -32, to: calendar.startOfDay(for: date))
            let periodAve = HKQuery.predicateForSamples(withStart: startDateAve, end: endDateAve)
            let stepsTodayAve = HKSamplePredicate.quantitySample(type: typeOfStepCount, predicate: periodAve)
            let sumOfStepsQueryAve = HKStatisticsQueryDescriptor(predicate: stepsTodayAve, options: .cumulativeSum)
            
            let endDate = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: date))
            let startDate = calendar.date(byAdding: .day, value: -2, to: calendar.startOfDay(for: date))
            let period = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
            let stepsToday = HKSamplePredicate.quantitySample(type: typeOfStepCount, predicate: period)
            let sumOfStepsQuery = HKStatisticsQueryDescriptor(predicate: stepsToday, options: .cumulativeSum)
            //１ヶ月の平均歩数を取得
            let stepCountAve = try await sumOfStepsQueryAve.result(for: myHealthStore)?.sumQuantity()?.doubleValue(for: HKUnit.count())
            //昨日の歩数を取得
            let stepCount = try await sumOfStepsQuery.result(for: myHealthStore)?.sumQuantity()?.doubleValue(for: HKUnit.count())
            var differencePoint = Int()
            var todayPoint = 0
            differencePoint = Int(stepCount ?? 0) - Int(stepCountAve ?? 0 / 30)
            switch differencePoint {
            case (-1000..<600): todayPoint = 3
            case (600...): todayPoint = Int(differencePoint / 150)
            default: break
            }
            try await FirebaseClient.shared.firebasePutData(point: todayPoint)
            UD.set(Date(), forKey: "today")
        }
    }
}
