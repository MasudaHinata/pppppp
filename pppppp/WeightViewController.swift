//
//  WeightViewController.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/06/15.
//

import UIKit
import HealthKit
import Firebase

class WeightViewController: UIViewController, UITextFieldDelegate {
    
    var myHealthStore = HKHealthStore()
    var typeOfBodyMass = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
    var weight: Double!
    
    
    @IBOutlet var weightTextField: UITextField!
    
    @IBAction func addButtonPressed() {
        guard let inputWeightText = weightTextField.text else { return }
        guard let inputWeight = Double(inputWeightText) else { return }
        saveWeight(weight: inputWeight)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let types = Set([typeOfBodyMass])
        let healthStore = HKHealthStore()
        healthStore.requestAuthorization(toShare: types, read: types, completion: { success, error in
            print(success)
        })
        
        self.weightTextField?.delegate = self
        read()
    }
    
    // firebaseにデータの保存.
    func saveWeight(weight: Double) {
        
        let quantity = HKQuantity(unit: HKUnit.gramUnit(with: .kilo), doubleValue: weight)
        let WeightData = HKQuantitySample(type: typeOfBodyMass, quantity: quantity, start: Date(), end: Date())
        
        self.myHealthStore.save(WeightData, withCompletion: {
            (success: Bool, error: Error!) in
            if success {
                NSLog("HealthKit保存成功!")
            } else {
                print("HealthKitできませんでした。")
            }
        })
        
        
        if let currentUser = Auth.auth().currentUser {
            let db = Firestore.firestore()
            db.collection("UserData")
                .document(currentUser.uid)
                .collection("weightData")
                .document("\(Date())") // サブコレクションであるprefecturesがない場合、自動でリストが生成される。
                .setData([
                    "weight": String(weight),
                    "date"  : Date(),
                ]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
        }
    }
    
        //データを取得
//    func read() {
//        let query = HKSampleQuery(sampleType: typeOfBodyMass, predicate: nil, limit: 1, sortDescriptors: nil) { (query, results, error) in
//            if results is [HKQuantitySample] {
//                print("\(query)")
//                print("データを取得しました")
//
//            }
//        }
//        myHealthStore.execute(query)
//    }
    
    func read() {
        
        let query = HKSampleQuery(sampleType: typeOfBodyMass, predicate: nil, limit: Int(1.0), sortDescriptors: nil) { (query, results, error) in
            if results is [HKQuantitySample] {
                if results is [HKQuantitySample] {
                    // 取得したデータを格納
                    print("体重ううううううは\(String(describing: results))")
                }
            }
        }
        myHealthStore.execute(query)
    }
    
//    func read(){
//            // 取得する期間を設定
//            let dateformatter = DateFormatter()
//            dateformatter.dateFormat = "yyyy/MM/dd"
//            let startDate = dateformatter.date(from: "2000/1/1")
//            let endDate = dateformatter.date(from: "2022/06/21")
//
//            // 取得するデータを設定
//            let typeOfWeight = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)
//            let statsOptions: HKStatisticsOptions = [HKStatisticsOptions.discreteMin, HKStatisticsOptions.discreteMax]
//
//            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions.strictStartDate)
//            let query = HKStatisticsQuery(quantityType: typeOfWeight!, quantitySamplePredicate: predicate, options: statsOptions, completionHandler: { (query, result, error) in
//                if let e = error {
//                    print("Error: \(e.localizedDescription)")
//                    return
//                }
//                DispatchQueue.main.async {
//                    guard let r = result else {
//                        return
//                    }
//                    let min = r.minimumQuantity()
//                    let max = r.maximumQuantity()
//                    if min != nil && max != nil {
//                        print("\(r.startDate) : \(r.endDate) 最小:\(min!) 最大:\(max!)")
//                    }
//                }
//            })
//            myHealthStore.execute(query)
//        }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        weightTextField.resignFirstResponder()
        return true
    }
    
}
