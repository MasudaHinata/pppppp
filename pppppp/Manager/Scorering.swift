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
            
            //TODO: ERRORHANDLING
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
            var todayPoint = Int()
            differencePoint = Int(stepCount!) - Int(stepCountAve! / 30)
            
            switch differencePoint {
            case (...0): todayPoint = 0
            case (0...500): todayPoint = 2
            case (500...1000): todayPoint = 3
            case (1000...2000): todayPoint = 5
            case (2000...3000): todayPoint = 10
            case (3000...4000): todayPoint = 15
            case (4000...5000): todayPoint = 20
            case (5000...6000): todayPoint = 25
            case (6000...7000): todayPoint = 30
            case (7000...8000): todayPoint = 35
            case (8000...9000): todayPoint = 40
            case (9000...10000): todayPoint = 45
            case (10000...11000): todayPoint = 50
            case (11000...12000): todayPoint = 55
            case (12000...13000): todayPoint = 60
            case (13000...14000): todayPoint = 65
            case (14000...15000): todayPoint = 70
            case (15000...16000): todayPoint = 75
            case (16000...17000): todayPoint = 80
            case (17000...18000): todayPoint = 85
            case (18000...19000): todayPoint = 90
            case (19000...20000): todayPoint = 95
            case (20000...): todayPoint = 100
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
