import Foundation
import HealthKit

var typeOfBodyMass = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
var typeOfStepCount = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!

final class ChartsManager {
    static let shared = ChartsManager()
    private init() {}
    
    let myHealthStore = HKHealthStore()
    let calendar = Calendar.current
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
    
    //MARK: - 平均歩数を取得
    func getAverageStepPoint(date: Double) async throws -> Int {
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
    
    //MARK: - Chart用の歩数を取得(Week)
    func createWeekStepsChart() async throws -> [ChartsStepItem] {
        getPermissionHealthKit()
        var chartsStepItem = [ChartsStepItem]()
        let days: [Int] = Array(-1...5)
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
        return chartsStepItem
    }
    
    //MARK: - Chart用の歩数を取得(Month)
    func createMonthStepsChart() async throws -> [ChartsStepItem] {
        getPermissionHealthKit()
        var chartsStepItem = [ChartsStepItem]()
        let days: [Int] = Array(-1...29)
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
        return chartsStepItem
    }
    
    //MARK: - Chart用の歩数を取得(Year)
    func createYearStepsChart() async throws -> [ChartsStepItem] {
        getPermissionHealthKit()
        var chartsStepItem = [ChartsStepItem]()
        let days: [Int] = Array(0...11)
        
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
            
//            print(startDate,endDate)
            
            let period = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
            let stepsToday = HKSamplePredicate.quantitySample(type: typeOfStepCount, predicate: period)
            let sumOfStepsQuery = HKStatisticsQueryDescriptor(predicate: stepsToday, options: .cumulativeSum)
            let stepCounts = try await sumOfStepsQuery.result(for: myHealthStore)?.sumQuantity()?.doubleValue(for: HKUnit.count())
            let stepdata = ChartsStepItem.init(date: startDate, stepCounts: Int((stepCounts ?? 0) / 31))
            chartsStepItem.append(stepdata)
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
        let descriptor = HKSampleQueryDescriptor(predicates:[.quantitySample(type: typeOfBodyMass)], sortDescriptors: [SortDescriptor(\.startDate, order: .reverse)], limit: 30)
        let results = try await descriptor.result(for: myHealthStore)
        for sample in results {
            let s = sample.quantity.doubleValue(for: .gramUnit(with: .kilo))
            let weightData = ChartsWeightItem.init(date: sample.startDate, weight: Double(s))
            chartsWeightItem.append(weightData)
        }
        return chartsWeightItem
    }
}
