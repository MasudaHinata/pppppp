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
            //期間の指定
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
            
            let stepCountAve = try await sumOfStepsQueryAve.result(for: myHealthStore)?.sumQuantity()?.doubleValue(for: HKUnit.count())
            let yesterdayStepCount = try await sumOfStepsQuery.result(for: myHealthStore)?.sumQuantity()?.doubleValue(for: HKUnit.count())
            
            var differencePoint = Int()
            var todayPoint = 0
            differencePoint = Int(yesterdayStepCount ?? 0) - Int(stepCountAve ?? 0 / 30)
            
            if Int(stepCountAve ?? 0 / 30) <= 7999 {
                switch differencePoint {
                case (120...15000): todayPoint = Int(differencePoint / 120)
                case (12000...): todayPoint = 100
                default: break
                }
            } else if Int(stepCountAve ?? 0 / 30) >= 8000 {
                switch differencePoint {
                case (Int(7500 - (stepCountAve ?? 0))..<1600): todayPoint = 15
                case (1600...10000): todayPoint = Int(differencePoint / 100)
                case (10000...): todayPoint = 100
                default: break
                }
            }
            try await FirebaseClient.shared.firebasePutData(point: todayPoint, activity: "Steps")
            UD.set(Date(), forKey: "today")
        }
    }
}
