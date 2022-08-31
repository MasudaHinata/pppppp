//
//  Scorering.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/08/09.
//

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
        let typeOfWrite = Set([typeOfBodyMass])
        let typeOfRead = Set([typeOfBodyMass, typeOfStepCount, typeOfHeight])
        myHealthStore.requestAuthorization(toShare: typeOfWrite, read: typeOfRead) { (success, error) in
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
            
            //        TODO: ERRORHANDLING
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
            //１ヶ月の平均歩数を取得
            let stepCountAve = try await sumOfStepsQueryAve.result(for: myHealthStore)?.sumQuantity()?.doubleValue(for: HKUnit.count())
            //昨日の歩数を取得
            let stepCount = try await sumOfStepsQuery.result(for: myHealthStore)?.sumQuantity()?.doubleValue(for: HKUnit.count())
            var differencePoint = Int()
            var todayPoint = 0
            differencePoint = Int(stepCount!) - Int(stepCountAve! / 30)
            
            switch differencePoint {
            case (-1000..<200): todayPoint = 3
            case (200...): todayPoint = Int(differencePoint / 200)
            default: break
            }
            
            try await FirebaseClient.shared.firebasePutData(point: todayPoint)
            UD.set(Date(), forKey: "today")
        }
    }
    //体重を取得
    func readWeight() async throws {
        //TODO: 日付の指定をする(HKSampleQueryDescriptor日付指定できる？)
        let descriptor = HKSampleQueryDescriptor(predicates:[.quantitySample(type: typeOfBodyMass)], sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)], limit: nil)
        let results = try await descriptor.result(for: myHealthStore)
        let doubleValues = results.map {
            $0.quantity.doubleValue(for: .gramUnit(with: .kilo))
        }
        print(doubleValues)
    }
    //体重を書き込み
    func writeWeight(weight: Double) async throws {
        let myWeight = HKQuantity(unit: HKUnit.gramUnit(with: .kilo), doubleValue: weight)
        let myWeightData = HKQuantitySample(type: typeOfBodyMass, quantity: myWeight, start: Date(),end: Date())
        try await self.myHealthStore.save(myWeightData)
    }
}
