//
//  WeightViewController.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/06/15.
//

import UIKit
import HealthKit
import Firebase

class WeightViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate,UITableViewDataSource {
    
    var myHealthStore = HKHealthStore()
    var typeOfBodyMass = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
    var weight: Double!
    
    
    @IBOutlet var weightTextField: UITextField!
    @IBOutlet var weighttable: UITableView!
    
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
        weighttable.delegate = self
        weighttable.dataSource = self
        
        print ("かいはつやめたい")
        
//        read()
    }
    
//    cellの数指定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
//    cellの中身
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let weigthcell = tableView.dequeueReusableCell(withIdentifier: "WeightCell")
        
        let query = HKSampleQuery(sampleType: typeOfBodyMass, predicate: nil, limit: Int(Double(0.1)), sortDescriptors: nil) { (query, results, error) in
            if results is [HKQuantitySample] {
                if results is [HKQuantitySample] {
                    // 取得したデータを格納
                    weigthcell?.textLabel?.text = "体重は\(String(describing: results))"
//                    print("体重は\(String(describing: results))")
                }
            }
        }
        myHealthStore.execute(query)
//        weigthcell?.textLabel?.text = "体重は\(String(describing: results))"
        
        return weigthcell!
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
    
    //データをHealthkitから取得
//    func read() {
//
//        let query = HKSampleQuery(sampleType: typeOfBodyMass, predicate: nil, limit: Int(Double(0.1)), sortDescriptors: nil) { (query, results, error) in
//            if results is [HKQuantitySample] {
//                if results is [HKQuantitySample] {
//                    // 取得したデータを格納
////                    print("体重は\(String(describing: results))")
//                }
//            }
//        }
//        myHealthStore.execute(query)
//    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        weightTextField.resignFirstResponder()
        return true
    }
    
}
