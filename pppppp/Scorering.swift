//
//  Scorering.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/08/09.
//

import Foundation
import HealthKit
import Firebase
import FirebaseFirestore

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
    
    //healthkit使用の許可
    func getPermissionHealthKit() {
        let typeOfWrite = Set([typeOfBodyMass])
        let typeOfRead = Set([typeOfBodyMass, typeOfStepCount, typeOfHeight])
        myHealthStore.requestAuthorization(toShare: typeOfWrite ,read: typeOfRead,completion: { (success, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            print(success)
        })
    }
    
    func createStepPoint() async throws {
        //TODO: ERRORHANDLING
        let endDateAve = calendar.date(byAdding: .day, value: -2, to: calendar.startOfDay(for: date))
        let startDateAve = calendar.date(byAdding: .day, value: -32, to: calendar.startOfDay(for: date))
        let periodAve = HKQuery.predicateForSamples(withStart: startDateAve, end: endDateAve)
        let stepsTodayAve = HKSamplePredicate.quantitySample(type: typeOfStepCount, predicate: periodAve)
        let sumOfStepsQueryAve = HKStatisticsQueryDescriptor(predicate: stepsTodayAve, options: .cumulativeSum)
        //１ヶ月の平均歩数を取得
        let stepCountAve = try await sumOfStepsQueryAve.result(for: myHealthStore)?.sumQuantity()?.doubleValue(for: HKUnit.count())
        print(stepCountAve!)
        print(startDateAve!,"から",endDateAve!,"までの平均歩数は",Int(stepCountAve! / 31))
        
        let endDate = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: date))
        let startDate = calendar.date(byAdding: .day, value: -2, to: calendar.startOfDay(for: date))
        let period = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let stepsToday = HKSamplePredicate.quantitySample(type: typeOfStepCount, predicate: period)
        print(startDate!,endDate!)
        let sumOfStepsQuery = HKStatisticsQueryDescriptor(predicate: stepsToday, options: .cumulativeSum)
        //昨日の歩数を取得
        let stepCount = try await sumOfStepsQuery.result(for: myHealthStore)?.sumQuantity()?.doubleValue(for: HKUnit.count())
        print(startDate!,"から",endDate!,"までの歩数は",Int(stepCount!))
        
        sanitasPoint = Int(stepCount!) - Int(stepCountAve! / 30)
        print(sanitasPoint)
        
        let task = Task { [weak self] in
            do {
                try await firebasePutData(point: sanitasPoint)
            }
            catch {
                //TODO: ERROR Handling
                print("error")
            }
        }
    }
    //ポイントをfirebaseに保存
    func firebasePutData(point: Int) async throws {
        let db = Firestore.firestore()
        let user = Auth.auth().currentUser
        
        db.collection("UserData").document(user!.uid).collection("HealthData").document("Date()").setData([
            "point": point
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    //体重を取得
    func readWeight() async throws {
        let endDate = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: date))
        let startDate = calendar.date(byAdding: .day, value: -31, to: calendar.startOfDay(for: date))
        
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
