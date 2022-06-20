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
//            print(error)
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
                print("HealthKit保存成功!")
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
    func read() {
        let query = HKSampleQuery(sampleType: typeOfBodyMass, predicate: nil, limit: 1, sortDescriptors: nil) { (query, results, error) in
            if results is [HKQuantitySample] {
                print("データを取得しました")
            }
        }
        myHealthStore.execute(query)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        weightTextField.resignFirstResponder()
        return true
    }
    
}
