import Foundation
import HealthKit

var typeOfBodyMass = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
var typeOfStepCount = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
var typeOfWorkout = HKWorkoutType.workoutType()

final class HealthKitManager {
    static let shared = HealthKitManager()
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
            print(try await descriptor.result(for: myHealthStore))
            for sample in try await descriptor.result(for: myHealthStore) {
                chartsWeightItem.append(ChartsWeightItem.init(date: sample.startDate, weight: Double(sample.quantity.doubleValue(for: .gramUnit(with: .kilo)))))
            }
        }
        return chartsWeightItem
    }
    //MARK: - Workoutを取得
    func readWorkoutData() async throws -> [WorkoutData] {
        getPermissionHealthKit()
        var workoutData = [WorkoutData]()
        
        let descriptor = HKSampleQueryDescriptor(predicates:[.workout()], sortDescriptors: [SortDescriptor(\.startDate, order: .reverse)])
        let results = try await descriptor.result(for: myHealthStore)
        
        //        print(results)
        //        print(results.last?.workoutActivityType.rawValue)
        //        print(results.last?.startDate)
        //        print(results.last?.totalEnergyBurned ?? 0)
        
        for workout in results {
            self.dateFormatter.dateFormat = "YY/MM/dd"
            let data = WorkoutData(date: self.dateFormatter.string(from:  workout.startDate), activityTypeID: Int(workout.workoutActivityType.rawValue), time: 0, energy: workout.totalEnergyBurned!)
            workoutData.append(data)
        }
        
        return workoutData
    }
}
