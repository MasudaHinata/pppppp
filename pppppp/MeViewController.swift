//
// MeViewController.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/06/15.
//

import UIKit
import HealthKit
import Firebase
import FirebaseFirestore

class MeViewController: UIViewController, UITextFieldDelegate {
    
    var myHealthStore = HKHealthStore()
    var typeOfBodyMass = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
    var weight: Double!
//    let userID = Auth.auth().currentUser!.uid
    
    
    @IBOutlet var weightTextField: UITextField!
    @IBOutlet var weightLabel: UILabel!
    @IBOutlet var mynameLabel: UILabel!
    
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
        
//        read()
    }

////    名前を表示
//    func getname() {
//
//        let db = Firestore.firestore()
//        let docRef = db.collection("UserData")
//            .document(userID)
//
//        docRef.getDocument { (document, error) in
//            if let document = document, document.exists {
//                print("友達の名前は\(document.data()!["name"]!)")
//                self.mynameLabel.text = "\(document.data()!["name"]!)"
//            } else {
//                print("存在してない")
//            }
//        }
//    }
    
    
    
    // firebaseに体重を保存.
    func saveWeight(weight: Double) {
        
        let quantity = HKQuantity(unit: HKUnit.gramUnit(with: .kilo), doubleValue: weight)
        let WeightData = HKQuantitySample(type: typeOfBodyMass, quantity: quantity, start: Date(), end: Date())
        
        self.myHealthStore.save(WeightData, withCompletion: {
            (success: Bool, error: Error!) in
            if success {
                NSLog("HealthKit保存成功!")
            } else {
                print("HealthKitに保存できませんでした。")
            }
        })
        
    }
    
//    //データをHealthkitから取得
//    func read() {
//        DispatchQueue.main.async { [self] in
//            let query = HKSampleQuery(sampleType: self.typeOfBodyMass, predicate: nil, limit: Int(Float(0.1)), sortDescriptors: nil) { (query, results, error) in
//                if results is [HKQuantitySample] {
//                    if results is [HKQuantitySample] {
//                        // 取得したデータを格納
//                        self.weightLabel.text = "体重は\(String(describing: results))"
//                        print("体重は\(String(describing: results))")
//                    }
//                }
//            }
//            myHealthStore.execute(query)
//        }
//    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        weightTextField.resignFirstResponder()
        return true
    }
    
}
