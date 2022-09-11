import Foundation
import HealthKit
import Combine

var cancellables = Set<AnyCancellable>()
let myHealthStore = HKHealthStore()
var typeOfBodyMass = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
var typeOfStepCount = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
var typeOfHeight = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!

final class Scorering {
    static let shared = Scorering()
    private init() {}
    
    let myHealthStore = HKHealthStore()
    let calendar = Calendar.current
    let UD = UserDefaults.standard
    
    func getPermissionHealthKit() {
        let typeOfRead = Set([typeOfStepCount])
        myHealthStore.requestAuthorization(toShare: nil, read: typeOfRead) { (success, error) in
            if let error = error {
                print("Scorering getPermission error:", error.localizedDescription)
                return
                //            } else if success {
                //                print("success")
                //                let task = Task {
                //                    do {
                //                        try await self.createStepPoint()
                //                    }
                //                    catch {
                //                        print("getpermission error: \(error.localizedDescription)")
                //                    }
                //                }
                //                cancellables.insert(.init { task.cancel() })
            }
        }
    }
    
    func getTodaySteps() async throws -> Double {
        getPermissionHealthKit()
        let startDate = calendar.startOfDay(for: Date())
        let period = HKQuery.predicateForSamples(withStart: startDate, end: Date())
        let stepsToday = HKSamplePredicate.quantitySample(type: typeOfStepCount, predicate: period)
        let sumOfStepsQuery = HKStatisticsQueryDescriptor(predicate: stepsToday, options: .cumulativeSum)
        let todayStepCount = try await sumOfStepsQuery.result(for: myHealthStore)?.sumQuantity()?.doubleValue(for: HKUnit.count())
        return todayStepCount ?? 0
    }
    
    func createStepPoint() async throws {
        getPermissionHealthKit()
        let endDateMonth = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: Date()))
        let startDateMonth = calendar.date(byAdding: .day, value: -31, to: calendar.startOfDay(for: Date()))
        let periodMonth = HKQuery.predicateForSamples(withStart: startDateMonth, end: endDateMonth)
        let stepsTodayMonth = HKSamplePredicate.quantitySample(type: typeOfStepCount, predicate: periodMonth)
        let sumOfStepsQueryMonth = HKStatisticsQueryDescriptor(predicate: stepsTodayMonth, options: .cumulativeSum)
        
        let endDate = calendar.date(byAdding: .day, value: -0, to: calendar.startOfDay(for: Date()))
        let startDate = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: Date()))
        let period = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let stepsToday = HKSamplePredicate.quantitySample(type: typeOfStepCount, predicate: period)
        let sumOfStepsQuery = HKStatisticsQueryDescriptor(predicate: stepsToday, options: .cumulativeSum)
        
        let monthStepCountSum = try await sumOfStepsQueryMonth.result(for: myHealthStore)?.sumQuantity()?.doubleValue(for: HKUnit.count())
        let yesterdayStepCount = try await sumOfStepsQuery.result(for: myHealthStore)?.sumQuantity()?.doubleValue(for: HKUnit.count())
        
        let monthStepCountAve = (monthStepCountSum ?? 0) / 30
        let differenceStep = Int(yesterdayStepCount ?? 0) - Int(monthStepCountAve)
        var todayPoint = 0
        if Int(monthStepCountAve) <= 7999 {
            switch differenceStep {
            case (120...15000): todayPoint = Int(differenceStep / 120)
            case (12000...): todayPoint = 100
            default: break
            }
        } else if Int(monthStepCountAve) >= 8000 {
            switch differenceStep {
            case (Int(7500 - monthStepCountAve)..<1600): todayPoint = 15
            case (1600...10000): todayPoint = Int(differenceStep / 100)
            case (10000...): todayPoint = 100
            default: break
            }
        }
        
        try await FirebaseClient.shared.firebasePutData(point: todayPoint, activity: "Steps")
    }
}
