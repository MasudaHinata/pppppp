import Foundation
import HealthKit

var typeOfBodyMass = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
var typeOfStepCount = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
var typeOfWorkout = HKWorkoutType.workoutType()

final class HealthKit_ScoreringManager {
    static let shared = HealthKit_ScoreringManager()
    private init() {}
    
    let myHealthStore = HKHealthStore()
    let dateFormatter = DateFormatter()
    let calendar = Calendar.current
    let typeOfWrite = Set([typeOfBodyMass])
    let typeOfRead = Set([typeOfBodyMass, typeOfStepCount, typeOfWorkout])
    
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
    
    //MARK: - 平均歩数を取得
    func getAverageStep(date: Double) async throws -> Int {
        getPermissionHealthKit()
        var averageStep = Int()
        let endDate = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date()))
        let startDate = calendar.date(byAdding: .day, value: Int(-date), to: calendar.startOfDay(for: Date()))
        let period = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let stepsToday = HKSamplePredicate.quantitySample(type: typeOfStepCount, predicate: period)
        let sumOfStepsQuery = HKStatisticsQueryDescriptor(predicate: stepsToday, options: .cumulativeSum)
        averageStep = Int((try await sumOfStepsQuery.result(for: myHealthStore)?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0) / (date + 1))
        return averageStep
    }
    
    //MARK: - Chart用の歩数を取得
    func getStepsChart(period: String) async throws -> [ChartsStepItem] {
        getPermissionHealthKit()
        var chartsStepItem = [ChartsStepItem]()
        var days = [Int]()
        
        if period == "year" {
            days = Array(0...11)
            let todayComps = calendar.dateComponents([.year, .month], from: Date())
            let todayAdds = DateComponents(month: 1, day: -1)
            let todayStartDate = calendar.date(from: todayComps)!
            let todayEndDate = calendar.date(byAdding: todayAdds, to: todayStartDate)!
            
            for month in days {
                let monthDate = calendar.date(byAdding: .month, value: -month, to: calendar.startOfDay(for: todayEndDate))
                let comps = calendar.dateComponents([.year, .month], from: monthDate!)
                let add = DateComponents(month: 1, day: -1)
                let startDate = calendar.date(from: comps)!
                let endDate = calendar.date(byAdding: add, to: startDate)!
                let period = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
                let stepsToday = HKSamplePredicate.quantitySample(type: typeOfStepCount, predicate: period)
                let sumOfStepsQuery = HKStatisticsQueryDescriptor(predicate: stepsToday, options: .cumulativeSum)
                let stepCounts = try await sumOfStepsQuery.result(for: myHealthStore)?.sumQuantity()?.doubleValue(for: HKUnit.count())
                let stepdata = ChartsStepItem.init(date: startDate, stepCounts: Int((stepCounts ?? 0) / 31))
                chartsStepItem.append(stepdata)
            }
        } else {
            if period == "month" {
                days = Array(-1...29)
            } else if period == "week" {
                days = Array(-1...5)
            }
            for date in days {
                let endDate = calendar.date(byAdding: .day, value: -date, to: calendar.startOfDay(for: Date()))
                let startDate = calendar.date(byAdding: .day, value: -(date + 1), to: calendar.startOfDay(for: Date()))
                let period = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
                let stepsToday = HKSamplePredicate.quantitySample(type: typeOfStepCount, predicate: period)
                let sumOfStepsQuery = HKStatisticsQueryDescriptor(predicate: stepsToday, options: .cumulativeSum)
                let stepCounts = try await sumOfStepsQuery.result(for: myHealthStore)?.sumQuantity()?.doubleValue(for: HKUnit.count())
                let stepdata = ChartsStepItem.init(date: startDate!, stepCounts: Int(stepCounts ?? 0))
                chartsStepItem.append(stepdata)
            }
        }
        return chartsStepItem
    }
    
    //MARK: - 歩数を取得・歩数ポイントを作成
    func createStepPoint() async throws {
        HealthKit_ScoreringManager.shared.getPermissionHealthKit()
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
        
        //MARK: 先月との歩数差のポイント
        if differenceStep <= 0 {
            stepDifPoint = 0
        } else {
            stepDifPoint = Int(9 / (0.3 + exp(-Double(differenceStep) * 0.0005)))
        }
        
        //MARK: 平均歩数のポイント
        if monthStepCountAve <= 6000 {
            stepAvePoint = 0
        } else {
            stepAvePoint = Int(0.5 / (0.05 + exp(-Double(monthStepCountAve) * 0.0004)))
        }
        
        let todayPoint = stepDifPoint + stepAvePoint
        try await FirebaseClient.shared.firebasePutData(point: todayPoint, activity: "Steps")
    }
    
    
    //MARK: - 最新の体重を取得
    func getWeight() async throws -> Double {
        getPermissionHealthKit()
        let descriptor = HKSampleQueryDescriptor(predicates:[.quantitySample(type: typeOfBodyMass)], sortDescriptors: [])
        let results = try await descriptor.result(for: myHealthStore)
        guard let doubleValues = results.last?.quantity.doubleValue(for: .gramUnit(with: .kilo)) else { return 0 }
        return doubleValues
    }
    
    //MARK: - Chart用の体重を取得
    func getWeightData(period: String) async throws -> [ChartsWeightItem] {
        getPermissionHealthKit()
        var chartsWeightItem = [ChartsWeightItem]()
        var days = [Int]()
        
        //TODO: 体重がなかったら日付の線だけ表示したい
        if period == "2month" {
            days = Array(-1...60)
        } else if period == "week" {
            days = Array(-1...5)
        }
        
        for date in days {
            let startDate = calendar.date(byAdding: .day, value: -(date + 1), to: calendar.startOfDay(for: Date()))
            let endDate = calendar.date(byAdding: .day, value: -date, to: calendar.startOfDay(for: Date()))
            let period = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
            let predicate = [HKSamplePredicate.quantitySample(type: typeOfBodyMass, predicate: period)]
            let descriptor = HKSampleQueryDescriptor(predicates: predicate, sortDescriptors: [SortDescriptor(\.startDate, order: .reverse)])
            
            let weightDataList = try await descriptor.result(for: myHealthStore)
            if weightDataList == [] {
                print("データなし　ラベル出す")
            } else {
                for sample in weightDataList {
                    chartsWeightItem.append(ChartsWeightItem.init(date: sample.startDate, weight: Double(sample.quantity.doubleValue(for: .gramUnit(with: .kilo)))))
                }
            }
        }
        return chartsWeightItem
    }
    
    //MARK: - 体重をHealthKitに書き込み
    func writeWeight(weight: Double) async throws {
        getPermissionHealthKit()
        let myWeight = HKQuantity(unit: HKUnit.gramUnit(with: .kilo), doubleValue: weight)
        let myWeightData = HKQuantitySample(type: typeOfBodyMass, quantity: myWeight, start: Date(),end: Date())
        try await self.myHealthStore.save(myWeightData)
    }
    
    //MARK: - 体重ポイント作成の判定
    func checkWeightPoint() async throws -> Bool {
        getPermissionHealthKit()
        let descriptor = HKSampleQueryDescriptor(predicates:[.quantitySample(type: typeOfBodyMass)], sortDescriptors: [])
        let results = try await descriptor.result(for: myHealthStore)
        
        var checkWeightPoint: Bool
        let lastDate = UserDefaults.standard.object(forKey: "createWeightPointDate") as? Date
        if UserDefaults.standard.object(forKey: "createWeightPointDate") as? Date == nil {
            checkWeightPoint = true
        } else {
            if results.last?.startDate != nil {
                if results.last?.startDate ?? Date() > lastDate ?? Date() {
                    checkWeightPoint = true
                } else {
                    checkWeightPoint = false
                }
            } else {
                checkWeightPoint = false
            }
        }
        return checkWeightPoint
    }
    
    //MARK: - 体重ポイントを作成
    func createWeightPoint(weightGoal: Double, weight: Double) async throws -> [Double] {
        
        let endDate = calendar.date(byAdding: .day, value: 0, to: calendar.startOfDay(for: Date()))
        let startDate = calendar.date(byAdding: .day, value: -12, to: calendar.startOfDay(for: endDate!))
        let period = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let predicate = [HKSamplePredicate.quantitySample(type: typeOfBodyMass, predicate: period)]
        let descriptor = HKSampleQueryDescriptor(predicates: predicate, sortDescriptors: [SortDescriptor(\.startDate, order: .reverse)])
        let lastWeightDataList = try await descriptor.result(for: myHealthStore)
        let lastweightList = lastWeightDataList.map { $0.quantity.doubleValue(for: .gramUnit(with: .kilo)) }
        
        if lastweightList != [] {
            var weightPoint: Int?
            
            if lastweightList.reduce(0, +) / Double(lastweightList.count) - weightGoal >= 0 {
                //減量
                if weightGoal >= weight {
                    weightPoint = 15
                } else {
                    let weightDifference = lastweightList.reduce(0, +) / Double(lastweightList.count) - weight
                    if weightDifference > 0 {
                        weightPoint = Int(3.5 / (0.3 + exp(-weightDifference * 3)))
                    }
                }
                try await FirebaseClient.shared.firebasePutData(point: weightPoint ?? 0, activity: "Weight")
            } else {
                //増量
                if weightGoal <= weight {
                    weightPoint = 15
                } else {
                    let weightDifference = lastweightList.reduce(0, +) / Double(lastweightList.count) - weight
                    if weightDifference < 0 {
                        weightPoint = Int(3.4 / (0.3 + exp(-weightDifference * 3)))
                    }
                }
                try await FirebaseClient.shared.firebasePutData(point: weightPoint ?? 0, activity: "Weight")
            }
        }
        UserDefaults.standard.set((Date()), forKey: "createWeightPointDate")
        
        return lastweightList
    }
    
    //MARK: - Workoutを取得
    func readWorkoutData() async throws -> [WorkoutData] {
        getPermissionHealthKit()
        self.dateFormatter.dateFormat = "YY/MM/dd"
        var workoutData = [WorkoutData]()
        
        let descriptor = HKSampleQueryDescriptor(predicates:[.workout()], sortDescriptors: [SortDescriptor(\.startDate, order: .reverse)])
        let results = try await descriptor.result(for: myHealthStore)
        
        //        print(results)
        //        print(results.last?.workoutActivityType.rawValue)
        //        print(results.last?.startDate)
        //        print(results.last?.totalEnergyBurned ?? 0)
        
        for workout in results {
            let data = WorkoutData(date: self.dateFormatter.string(from:  workout.startDate), activityTypeID: Int(workout.workoutActivityType.rawValue), time: 0, energy: workout.totalEnergyBurned!)
            workoutData.append(data)
        }
        print(workoutData)
        return workoutData
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
}
