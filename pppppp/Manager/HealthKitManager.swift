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
    func createStepsChart(period: String) async throws -> [ChartsStepItem] {
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
//                dateFormatter.dateFormat = "MM"
//                let stepdata = ChartsStepItem.init(date: dateFormatter.string(from: startDate), stepCounts: Int((stepCounts ?? 0) / 31))
                
                
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
                dateFormatter.dateFormat = "MM/dd"
                let stepdata = ChartsStepItem.init(date: startDate!, stepCounts: Int(stepCounts ?? 0))
                //            let stepdata = ChartsStepItem.init(date: startDate!, stepCounts: Int(stepCounts ?? 0))
                chartsStepItem.append(stepdata)
            }
        }
        return chartsStepItem
    }
    
    //MARK: - 最新の体重を取得
    func readWeight() async throws -> Double {
        getPermissionHealthKit()
        let descriptor = HKSampleQueryDescriptor(predicates:[.quantitySample(type: typeOfBodyMass)], sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)], limit: nil)
        let results = try await descriptor.result(for: myHealthStore)
        guard let doubleValues = results.first?.quantity.doubleValue(for: .gramUnit(with: .kilo)) else { return 0 }
        let weight = (round(doubleValues * 10)) / 10
        return weight
    }
    
    //MARK: - Chart用の体重を取得
    func readWeightData() async throws -> [ChartsWeightItem] {
        getPermissionHealthKit()
        var chartsWeightItem = [ChartsWeightItem]()
        
        //        //TODO: 期間を指定して週・月・年で分ける
        //async
        
                let descriptor = HKSampleQueryDescriptor(predicates:[.quantitySample(type: typeOfBodyMass)], sortDescriptors: [SortDescriptor(\.startDate, order: .reverse)], limit: 7)
                let results = try await descriptor.result(for: myHealthStore)
                for sample in results {
                            let s = sample.quantity.doubleValue(for: .gramUnit(with: .kilo))
                            let weightData = ChartsWeightItem.init(date: sample.startDate, weight: Double(s))
                    chartsWeightItem.append(weightData)
                }
        
//        //TODO: データが飛ばない
//        //asyncなし
//        let start = Calendar.current.date(byAdding: .month, value: -48, to: Date())
//        let end = Date()
//        let predicate = HKQuery.predicateForSamples(withStart: start, end: end)
//        let sampleType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
//
//        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
//
//            let samples = results as! [HKQuantitySample]
//            for sample in samples {
//                let sam = sample.quantity.doubleValue(for: .gramUnit(with: .kilo))
//                let weightData = ChartsWeightItem.init(date: sample.startDate, weight: Double(sam))
//                chartsWeightItem.append(weightData)
//            }
//            print(chartsWeightItem)
//        }
//        self.myHealthStore.execute(query)
        
        return chartsWeightItem
    }
    
    //MARK: - Workoutを取得
    func readWorkoutData() -> [WorkoutData] {
        getPermissionHealthKit()
        var workoutData = [WorkoutData]()
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        let query = HKSampleQuery(sampleType: typeOfWorkout, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) {  (query, result, error) in
            
            guard error == nil else {
                print("Error: \(error?.localizedDescription ?? "nil")")
                return
            }
            guard result != nil else {
                return
            }
//                        let lastWorkout = result as! [HKWorkout]
//                        print(lastWorkout.last?.workoutActivityType.rawValue)
//                        print(lastWorkout.last?.startDate)
//                        print(lastWorkout.last?.totalEnergyBurned ?? 0)
            
            for workout in result as! [HKWorkout] {
                self.dateFormatter.dateFormat = "YY/MM/dd"
                let data = WorkoutData(date: self.dateFormatter.string(from:  workout.startDate), activityTypeID: Int(workout.workoutActivityType.rawValue), time: 0, energy: workout.totalEnergyBurned!)
                
                workoutData.append(data)
            }
            print(workoutData)
        }
        myHealthStore.execute(query)
        return workoutData
    }
}
