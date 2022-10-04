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
        let descriptor = HKSampleQueryDescriptor(predicates:[.quantitySample(type: typeOfBodyMass)], sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)], limit: nil)
        let results = try await descriptor.result(for: myHealthStore)
        guard let doubleValues = results.first?.quantity.doubleValue(for: .gramUnit(with: .kilo)) else { return 0 }
        return doubleValues
    }
    
    //MARK: - Chart用の体重を取得
    func getWeightData() async throws -> [ChartsWeightItem] {
        getPermissionHealthKit()
        var chartsWeightItem = [ChartsWeightItem]()
        
        //FIXME: 期間を指定して週・月・年で分ける  async
        
        let startDate = Calendar.current.date(byAdding: .day, value: -60, to: Date())
        let endDate = Date()
        let period = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let predicate = [HKSamplePredicate.quantitySample(type: typeOfBodyMass, predicate: period)]
        let descriptor = HKSampleQueryDescriptor(predicates: predicate, sortDescriptors: [SortDescriptor(\.startDate, order: .reverse)])
    
        let results = try await descriptor.result(for: myHealthStore)
        for sample in results {
            let s = sample.quantity.doubleValue(for: .gramUnit(with: .kilo))
            let weightData = ChartsWeightItem.init(date: sample.startDate, weight: Double(s))
            chartsWeightItem.append(weightData)
        }
        return chartsWeightItem
    }
    
    //MARK: - Workoutを取得
    func readWorkoutData() async throws -> [WorkoutData] {
        getPermissionHealthKit()
        var workoutData = [WorkoutData]()
        
        let descriptor = HKSampleQueryDescriptor(predicates:[.workout()], sortDescriptors: [SortDescriptor(\.startDate, order: .reverse)])
//        let descriptor = HKSampleQueryDescriptor(predicates: predicate, sortDescriptors: [SortDescriptor(\.startDate, order: .reverse)])
    
        let results = try await descriptor.result(for: myHealthStore)
        for sample in results {
            print(sample)
//            let s = sample.quantity.doubleValue(for: .gramUnit(with: .kilo))
//            let weightData = WorkoutData
//            workoutData.append(weightData)
        }
        print(results)
        
        
//        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
//
//        let query = HKSampleQuery(sampleType: typeOfWorkout, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) {  (query, result, error) in
//
//            guard error == nil else {
//                print("Error: \(error?.localizedDescription ?? "nil")")
//                return
//            }
//            guard result != nil else {
//                return
//            }
//            //                        let lastWorkout = result as! [HKWorkout]
//            //                        print(lastWorkout.last?.workoutActivityType.rawValue)
//            //                        print(lastWorkout.last?.startDate)
//            //                        print(lastWorkout.last?.totalEnergyBurned ?? 0)XME: データが飛ばない  asyncなし
//            for workout in result as! [HKWorkout] {
//                self.dateFormatter.dateFormat = "YY/MM/dd"
//                let data = WorkoutData(date: self.dateFormatter.string(from:  workout.startDate), activityTypeID: Int(workout.workoutActivityType.rawValue), time: 0, energy: workout.totalEnergyBurned!)
//
//                workoutData.append(data)
//            }
//            //            print(workoutData)
//        }
//        myHealthStore.execute(query)

        return workoutData
    }
}
