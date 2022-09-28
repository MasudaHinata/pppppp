import Foundation
import HealthKit
import Combine

//var typeOfBodyMass = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
//var typeOfStepCount = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
//var typeOfHeight = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!

final class Scorering {
    static let shared = Scorering()
    private init() {}
    
    let myHealthStore = HKHealthStore()
    let calendar = Calendar.current
    var cancellables = Set<AnyCancellable>()
    let typeOfWrite = Set([typeOfBodyMass])
    let typeOfRead = Set([typeOfBodyMass, typeOfStepCount])
    
    //MARK: - HealthKitの許可を求める
    func getPermissionHealthKit() {
        //TODO: 許可されてるかどうかを判定する
        myHealthStore.requestAuthorization(toShare: typeOfWrite, read: typeOfRead) { (success, error) in
            if let error = error {
                print("Scorering getPermission error:", error.localizedDescription)
                return
            }
        }
    }
    
    //MARK: - 今日の歩数を取得
    func getTodaySteps() async throws -> Double {
        getPermissionHealthKit()
        let startDate = calendar.startOfDay(for: Date())
        let period = HKQuery.predicateForSamples(withStart: startDate, end: Date())
        let stepsToday = HKSamplePredicate.quantitySample(type: typeOfStepCount, predicate: period)
        let sumOfStepsQuery = HKStatisticsQueryDescriptor(predicate: stepsToday, options: .cumulativeSum)
        let todayStepCount = try await sumOfStepsQuery.result(for: myHealthStore)?.sumQuantity()?.doubleValue(for: HKUnit.count())
        return todayStepCount ?? 0
    }
    
    //MARK: - 歩数ポイントを作成
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
        var stepDifPoint = Int()
        var stepAvePoint = Int()
        
        //先月との歩数差のポイント
        if differenceStep <= 0 {
            stepDifPoint = 0
        } else {
            stepDifPoint = Int(9 / (0.3 + exp(-Double(differenceStep) * 0.0005)))
        }
        
        //平均歩数のポイント
        if monthStepCountAve <= 6000 {
            stepAvePoint = 0
        } else {
            stepAvePoint = Int(0.5 / (0.05 + exp(-Double(monthStepCountAve) * 0.0004)))
        }
        
        let todayPoint = stepDifPoint + stepAvePoint
        try await FirebaseClient.shared.firebasePutData(point: todayPoint, activity: "Steps")
    }
    
    //MARK: - 入力した運動と時間からポイントを作成
    func createExercisePoint(exercisesName: String, time: Float) async throws {
        var metz = Float()
        var exercizeName = exercisesName
        switch exercizeName {
        case "軽いジョギング":
            metz = 6.0
            exercizeName = "ジョギング"
        case "ランニング":
            metz = 4.5
        case "筋トレ(軽・中等度)":
            metz = 3.5
            exercizeName = "筋トレ"
        case "筋トレ(強等度)":
            metz = 6.0
            exercizeName = "筋トレ"
        case "テニス(ダブルス)":
            metz = 4.5
            exercizeName = "テニス"
        case "テニス(シングルス)":
            metz = 7.3
            exercizeName = "テニス"
        case "水泳(ゆっくりとした背泳ぎ・平泳ぎ)":
            metz = 5.0
            exercizeName = "水泳"
        case "水泳(クロール・普通の速さ)":
            metz = 8.3
            exercizeName = "水泳"
        case "水泳(クロール・速い)":
            metz = 10
            exercizeName = "水泳"
        case "野球":
            metz = 4.5
        default:
            print("error")
        }
        var exercisePoint = Int()
        let exercise = metz * (time / 60)
        if exercise <= 1 {
            exercisePoint = Int(4.5 / (0.45 + exp(-exercise * 6)))
        } else {
            exercisePoint = Int(15 / (0.6 + exp(-exercise * 0.2)))
        }
        try await FirebaseClient.shared.firebasePutData(point: exercisePoint, activity: exercizeName)
    }
    
    //MARK: - 体重をHealthKitに書き込み
    func writeWeight(weight: Double) async throws {
        getPermissionHealthKit()
        let myWeight = HKQuantity(unit: HKUnit.gramUnit(with: .kilo), doubleValue: weight)
        let myWeightData = HKQuantitySample(type: typeOfBodyMass, quantity: myWeight, start: Date(),end: Date())
        try await self.myHealthStore.save(myWeightData)
    }
}
