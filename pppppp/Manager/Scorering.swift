import Foundation
import HealthKit
import Combine

var typeOfBodyMass = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
var typeOfStepCount = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
//var typeOfHeight = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!

final class Scorering {
    static let shared = Scorering()
    private init() {}
    
    let myHealthStore = HKHealthStore()
    let calendar = Calendar.current
    var cancellables = Set<AnyCancellable>()
    
    let typeOfWrite = Set([typeOfBodyMass])
    let typeOfRead = Set([typeOfBodyMass, typeOfStepCount])
    
    //HealthKitの許可を求める
    func getPermissionHealthKit() {
        //TODO: 許可されてるかどうかを判定する
        myHealthStore.requestAuthorization(toShare: typeOfWrite, read: typeOfRead) { (success, error) in
            if let error = error {
                print("Scorering getPermission error:", error.localizedDescription)
                return
            }
        }
    }
    
    //今日の歩数を取得
    func getTodaySteps() async throws -> Double {
        getPermissionHealthKit()
        let startDate = calendar.startOfDay(for: Date())
        let period = HKQuery.predicateForSamples(withStart: startDate, end: Date())
        let stepsToday = HKSamplePredicate.quantitySample(type: typeOfStepCount, predicate: period)
        let sumOfStepsQuery = HKStatisticsQueryDescriptor(predicate: stepsToday, options: .cumulativeSum)
        let todayStepCount = try await sumOfStepsQuery.result(for: myHealthStore)?.sumQuantity()?.doubleValue(for: HKUnit.count())
        return todayStepCount ?? 0
    }
    
    //歩数ポイントを作成
    func createStepPoint() async throws {
        getPermissionHealthKit()
//        let endDateMonth = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: Date()))
//        let startDateMonth = calendar.date(byAdding: .day, value: -31, to: calendar.startOfDay(for: Date()))
//        let periodMonth = HKQuery.predicateForSamples(withStart: startDateMonth, end: endDateMonth)
//        let stepsTodayMonth = HKSamplePredicate.quantitySample(type: typeOfStepCount, predicate: periodMonth)
//        let sumOfStepsQueryMonth = HKStatisticsQueryDescriptor(predicate: stepsTodayMonth, options: .cumulativeSum)
//
//        let endDate = calendar.date(byAdding: .day, value: -0, to: calendar.startOfDay(for: Date()))
//        let startDate = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: Date()))
//        let period = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
//        let stepsToday = HKSamplePredicate.quantitySample(type: typeOfStepCount, predicate: period)
//        let sumOfStepsQuery = HKStatisticsQueryDescriptor(predicate: stepsToday, options: .cumulativeSum)
//
//        let monthStepCountSum = try await sumOfStepsQueryMonth.result(for: myHealthStore)?.sumQuantity()?.doubleValue(for: HKUnit.count())
//        let yesterdayStepCount = try await sumOfStepsQuery.result(for: myHealthStore)?.sumQuantity()?.doubleValue(for: HKUnit.count())
//
//        let monthStepCountAve = (monthStepCountSum ?? 0) / 30
//        let differenceStep = Int(yesterdayStepCount ?? 0) - Int(monthStepCountAve)
//        var todayPoint = 0
//
//        if Int(monthStepCountAve) <= 7999 {
//            switch differenceStep {
//            case (120...9600): todayPoint = Int(differenceStep / 120)
//            case (9600...): todayPoint = 80
//            default: break
//            }
//        } else if Int(monthStepCountAve) >= 8000 {
//            switch differenceStep {
//            case (Int(7500 - monthStepCountAve)..<1600): todayPoint = 15
//            case (1600...8000): todayPoint = Int(differenceStep / 100)
//            case (8000...): todayPoint = 80
//            default: break
//            }
//        }
        
        //TODO: スコアリングいい感じにする
        let differenceStep = 3000
        var todayPoint = 0
        
        if differenceStep > 0 {
            todayPoint = Int(30 / (1.0 + exp(-Double(differenceStep) * 0.0003)))
        } else {
            todayPoint = 0
        }
        
        print(todayPoint)
        
//        try await FirebaseClient.shared.firebasePutData(point: todayPoint, activity: "Steps")
    }
    
    //体重をHealthKitに書き込み
    func writeWeight(weight: Double) async throws {
        getPermissionHealthKit()
        let myWeight = HKQuantity(unit: HKUnit.gramUnit(with: .kilo), doubleValue: weight)
        let myWeightData = HKQuantitySample(type: typeOfBodyMass, quantity: myWeight, start: Date(),end: Date())
        try await self.myHealthStore.save(myWeightData)
    }
    
    //体重を読み込み
    func readWeight() async throws {
        getPermissionHealthKit()
        //TODO: 日付の指定をする(HKSampleQueryDescriptor日付指定できる？) &　日付と体重をWeightDataに入れたい
        
        let descriptor = HKSampleQueryDescriptor(predicates:[.quantitySample(type: typeOfBodyMass)], sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)], limit: nil)
        let results = try await descriptor.result(for: myHealthStore)
        let doubleValues = results.map {
            $0.quantity.doubleValue(for: .gramUnit(with: .kilo))
        }
        print(doubleValues)
        
        
        //        let query = HKSampleQuery(sampleType: typeOfBodyMass, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
        //            let samples = results as! [HKQuantitySample]
        //
        //            var buf = ""
        //            for sample in samples {
        //                let s = sample.quantity
        //                print("\(String(describing: sample))")
        //                buf.append("\(sample.startDate) \(String(describing: s))\n")
        //            }
        //            print(buf)
        //        }
        //        myHealthStore.execute(query)
    }
}
