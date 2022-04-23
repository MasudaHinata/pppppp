import UIKit
import HealthKit
import Firebase
import SwiftUI

class ViewController: UIViewController,UITextFieldDelegate {
    
    var me: User!
    var auth: Auth!
    let db = Firestore.firestore()
    var myHealthStore = HKHealthStore()
    var typeOfBodyMass = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
    var weight: Double! {
        didSet {
            DispatchQueue.main.async {
                self.titleTextField.text = String(self.weight)
            }
        }
    }
    
    

    
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var loginLabel: UILabel!
    
//    体重を追加する
    @IBAction func addButton() {
        saveWeight(weight: )
    }
    
//    設定画面に飛ぶ
    @IBAction func SettingButton() {
        
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
           //user情報なし。ログインにとばす
               //self.auth.currentUser?.isEmailVerified == true
               //self.performSegue(withIdentifier: "toCreateAccount", sender: nil)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let secondVC = storyboard.instantiateViewController(identifier: "AccountViewController")
                    showDetailViewController(secondVC, sender: self)
        }
    }
    
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

        //label.text = saveData.string(forKey: "key")

        
    }
    
//    let saveData: UserDefaults = UserDefaults.standard

    // firebaseにデータの保存.
    func saveWeight(weight: Double) {

        let quantity = HKQuantity(unit: HKUnit.gramUnit(with: .kilo), doubleValue: weight)
        let WeightData = HKQuantitySample(type: typeOfBodyMass, quantity: quantity, start: Date(), end: Date())

        self.myHealthStore.save(WeightData, withCompletion: {
            (success: Bool, error: Error!) in
            if success {
                NSLog("成功!")
            } else {
                print("失敗、エラー")
            }
        })
        
    

//        if Auth.auth().currentUser != nil {
//            let dataStore = Firestore.firestore()
//            let db = Firestore.firestore()
//            db.collection("UserData")
//                        .document("UUID()")
//                        .collection("weightData") // サブコレクションであるprefecturesがない場合、自動でリストが生成される。
//                        .document("weightData()")
//                        .setData([
//                            "weight": "weight",
//            ]) { err in
//                if let err = err {
//                    print("Error writing document: \(err)")
//                } else {
//                    print("Document successfully written!")
//                }
//            }
//
//        }
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
    
    // キーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            titleTextField.resignFirstResponder()
            return true
    }
}
