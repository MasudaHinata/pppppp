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
    let dateFormatter = DateFormatter()
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
    
    //MARK: - Chart用の歩数を取得(Week)
    func createWeekStepsChart() async throws -> [ChartsStepItem] {
        getPermissionHealthKit()
        dateFormatter.dateFormat = "MM/dd"
        var chartsStepItem = [ChartsStepItem]()
        let days = [-1, 0, 1, 2, 3, 4, 5]
        for date in days {
            let endDate = calendar.date(byAdding: .day, value: -date, to: calendar.startOfDay(for: Date()))
            let startDate = calendar.date(byAdding: .day, value: -(date + 1), to: calendar.startOfDay(for: Date()))
            let period = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
            let stepsToday = HKSamplePredicate.quantitySample(type: typeOfStepCount, predicate: period)
            let sumOfStepsQuery = HKStatisticsQueryDescriptor(predicate: stepsToday, options: .cumulativeSum)
            let stepCounts = try await sumOfStepsQuery.result(for: myHealthStore)?.sumQuantity()?.doubleValue(for: HKUnit.count())
            
            let stepdata = ChartsStepItem.init(date: dateFormatter.string(from: startDate!), stepCounts: Int(stepCounts ?? 0))
            chartsStepItem.append(stepdata)
        }
        return chartsStepItem
    }
    
    //MARK: - Chart用の歩数を取得(Month)
    func createMonthStepsChart() async throws -> [ChartsStepItem] {
        getPermissionHealthKit()
        dateFormatter.dateFormat = "MM/dd"
        var chartsStepItem = [ChartsStepItem]()
        let days: [Int] = Array(-1...30)
        for date in days {
            let endDate = calendar.date(byAdding: .day, value: -date, to: calendar.startOfDay(for: Date()))
            let startDate = calendar.date(byAdding: .day, value: -(date + 1), to: calendar.startOfDay(for: Date()))
            let period = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
            let stepsToday = HKSamplePredicate.quantitySample(type: typeOfStepCount, predicate: period)
            let sumOfStepsQuery = HKStatisticsQueryDescriptor(predicate: stepsToday, options: .cumulativeSum)
            let stepCounts = try await sumOfStepsQuery.result(for: myHealthStore)?.sumQuantity()?.doubleValue(for: HKUnit.count())
            
            let stepdata = ChartsStepItem.init(date: dateFormatter.string(from: startDate!), stepCounts: Int(stepCounts ?? 0))
            chartsStepItem.append(stepdata)
        }
        return chartsStepItem
    }
    
    //MARK: - 平均歩数を取得
    func getAverageStepPoint() async throws -> Int {
        getPermissionHealthKit()
        var averageStep = Int()
        let endDateMonth = calendar.date(byAdding: .day, value: 0, to: calendar.startOfDay(for: Date()))
        let startDateMonth = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: Date()))
        let periodMonth = HKQuery.predicateForSamples(withStart: startDateMonth, end: endDateMonth)
        let stepsTodayMonth = HKSamplePredicate.quantitySample(type: typeOfStepCount, predicate: periodMonth)
        let sumOfStepsQueryMonth = HKStatisticsQueryDescriptor(predicate: stepsTodayMonth, options: .cumulativeSum)
        averageStep = Int((try await (sumOfStepsQueryMonth.result(for: myHealthStore)?.sumQuantity()?.doubleValue(for: HKUnit.count())) ?? 0) / 7)
        return averageStep
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
        case "サイクリング":
            metz = 4.5
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
    
    //MARK: - 体重を読み込み
    func readWeight() async throws -> Double {
        getPermissionHealthKit()
        //TODO: 日付の指定をする(HKSampleQueryDescriptor日付指定できる？) &　日付と体重を構造体にいれてグラフにする
        let descriptor = HKSampleQueryDescriptor(predicates:[.quantitySample(type: typeOfBodyMass)], sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)], limit: nil)
        let results = try await descriptor.result(for: myHealthStore)
        let doubleValues = results.map {
            $0.quantity.doubleValue(for: .gramUnit(with: .kilo))
        }
        return doubleValues.first ?? 0
    }
    
    //MARK: - Chart用の体重を取得
    func createWeightChart() async throws -> [ChartsWeightItem] {
        getPermissionHealthKit()
        dateFormatter.dateFormat = "MM/dd"
        var chartsWeightItem = [ChartsWeightItem]()
        
        let predicate = HKQuery.predicateForSamples(withStart: nil, end: Date())
        let sampleType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        
        let query = HKSampleQuery(
            sampleType: sampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { [self]
                (query, results, error) in
                let samples = results as! [HKQuantitySample]
//                print(samples)
                for sample in samples {
                    let s = sample.quantity.doubleValue(for: .gramUnit(with: .kilo))
                    let weightData = ChartsWeightItem.init(date: dateFormatter.string(from: sample.startDate), weight: Float(s))
//                    print(weightData)
                    chartsWeightItem.append(weightData)
                }
                print(chartsWeightItem)
            }
        self.myHealthStore.execute(query)
//        print(chartsWeightItem)
        return chartsWeightItem
    }
}

//        let days = [-1, 0, 1, 2, 3, 4, 5]
//        for date in days {
//            let endDate = calendar.date(byAdding: .day, value: -date, to: calendar.startOfDay(for: Date()))
//            let startDate = calendar.date(byAdding: .day, value: -(date + 1), to: calendar.startOfDay(for: Date()))
//            let period = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
//            let stepsToday = HKSamplePredicate.quantitySample(type: typeOfStepCount, predicate: period)
//            let sumOfStepsQuery = HKStatisticsQueryDescriptor(predicate: stepsToday, options: .cumulativeSum)
//            let stepCounts = try await sumOfStepsQuery.result(for: myHealthStore)?.sumQuantity()?.doubleValue(for: HKUnit.count())
//
//            let weightData = ChartsWeightItem.init(date: dateFormatter.string(from: startDate!), weight: Int(stepCounts ?? 0))
//            chartsWeightItem.append(weightData)
//        }
