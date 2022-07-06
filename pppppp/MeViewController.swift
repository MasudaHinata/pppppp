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
    let userID = Auth.auth().currentUser!.uid
    
    
    @IBOutlet var weightTextField: UITextField!
    @IBOutlet var mynameLabel: UILabel!
    @IBAction func addButtonPressed() {
        guard let inputWeightText = weightTextField.text else { return }
        guard let inputWeight = Double(inputWeightText) else { return }
        saveWeight(weight: inputWeight)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ツールバーのインスタンスを作成
             let toolBar = UIToolbar()

             // ツールバーに配置するアイテムのインスタンスを作成
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let okButton: UIBarButtonItem = UIBarButtonItem(title: "OK", style: UIBarButtonItem.Style.plain, target: self, action: #selector(tapOkButton(_:)))

             // アイテムを配置
             toolBar.setItems([flexibleItem, okButton, flexibleItem], animated: true)

             // ツールバーのサイズを指定
             toolBar.sizeToFit()

             // テキストフィールドにツールバーを設定
            weightTextField.inputAccessoryView = toolBar
        
    //HealthKitの許可
        let types = Set([typeOfBodyMass])
        myHealthStore.requestAuthorization(toShare: types, read: types, completion: { success, error in
            print(success)
        })
        
        let readTypes = Set([
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount )!
        ])
        
        myHealthStore.requestAuthorization(toShare: [], read: readTypes, completion: { success, error in
            print(success)
        })
        
        let heightTypes = Set([
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!
        ])
        myHealthStore.requestAuthorization(toShare: [], read: heightTypes, completion: { success, error in
            print(success)
        })
        
        self.weightTextField?.delegate = self
        getname()
    }
    //体重を保存.
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
    
    //    身長を取得
    func readheight() {
        
        
        
    }
    
    //歩数を取得
    func readsteps (){
        

    }
    
    //    体重を取得
    @IBAction func readweight() {
        DispatchQueue.main.async { [self] in
            let query = HKSampleQuery(sampleType: self.typeOfBodyMass, predicate: nil, limit: Int(Float(0.1)), sortDescriptors: nil) { (query, results, error) in
                if results is [HKQuantitySample] {
                    if results is [HKQuantitySample] {
                        // 取得したデータを格納
                        
                        print("体重は\(String(describing: results))")
                    }
                }
            }
            myHealthStore.execute(query)
        }
    }
    
    //    名前を表示
    func getname() {
        
        let db = Firestore.firestore()
        db.collection("UserData").document(userID).getDocument { (snapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if let snapshot = snapshot {
                    let user = snapshot.data()!["name"]!
                    print(user)
                    self.mynameLabel.text = user as? String
                }
            }
        }
    }
    
    @objc func tapOkButton(_ sender: UIButton){
        // キーボードを閉じる
        self.view.endEditing(true)
    }
    
}
//extension MeViewController: UITextFieldDelegate {
//    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        weightTextField.resignFirstResponder()
//        return true
//    }
//}
