import UIKit
import HealthKit
import Firebase
import SwiftUI

class ViewController: UIViewController {
    
    var me: User!
    var auth: Auth!
    let db = Firestore.firestore()
    var myHealthStore = HKHealthStore()
    var typeOfBodyMass = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
    var weight: Double!
    
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var loginLabel: UILabel!
    
    override func viewDidLoad() {
            super.viewDidLoad()

            auth = Auth.auth()

            let types = Set([typeOfBodyMass])
            let healthStore = HKHealthStore()
            healthStore.requestAuthorization(toShare: types, read: types, completion: { success, error in
                print(success)
                print(error)
            })
            self.titleTextField?.delegate = self
            read()
        }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        //ログインできてるかどうかの判定
        if auth.currentUser != nil {
            auth.currentUser?.reload(completion: { [self] error in
                if error == nil {
                    if self.auth.currentUser?.isEmailVerified == true {
                        return //login ok
                        loginLabel.text = "ログイン中"
                    } else {
                        //メール認証がまだ
                        if self.auth.currentUser?.isEmailVerified == false {
                            let alert = UIAlertController(title: "確認用メールを送信しているので確認をお願いします。", message: "まだメール認証が完了していません。", preferredStyle: .alert)
                                                         alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                                         self.present(alert, animated: true, completion: nil)
                                                     }
                    }
                }
            })
        } else {
            //loginに飛ばす
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let secondVC = storyboard.instantiateViewController(identifier: "AccountViewController")
                    showDetailViewController(secondVC, sender: self)
        }
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
        
        @IBAction func addButtonPressed() {
             guard let inputWeightText = titleTextField.text else { return }
             guard let inputWeight = Double(inputWeightText) else { return }
             saveWeight(weight: inputWeight)
         }
}

    extension ViewController: UITextFieldDelegate {
        // キーボードを閉じる
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
                titleTextField.resignFirstResponder()
                return true
        }
    }
