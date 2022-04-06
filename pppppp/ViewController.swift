import UIKit
import HealthKit
import Firebase

class ViewController: UIViewController,UITextFieldDelegate {
    
    var me: User!
    var auth: Auth!
   
    
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var loginLabel: UILabel!

    @IBAction func addButton() {
        saveWeight(weight: 40)
    }
    
    @IBAction func SettingButton() {
        
    }
    
    @IBAction func logoutButton() {
            let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let secondVC = storyboard.instantiateViewController(identifier: "AccountViewController")
                showDetailViewController(secondVC, sender: self)
        
    }

    let db = Firestore.firestore()
    
    var myHealthStore = HKHealthStore()
    var typeOfBodyMass = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
    var bodyMass: Double = 0 {
        didSet {
            DispatchQueue.main.async {
                self.titleTextField.text = String(self.bodyMass)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

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
        
        titleTextField?.delegate = self
        read()

        //label.text = saveData.string(forKey: "key")

        
    }
    
//    let saveData: UserDefaults = UserDefaults.standard

    // データの保存.
    func saveWeight(weight: Double) {
        
        let quantity = HKQuantity(unit: HKUnit.gramUnit(with: .kilo), doubleValue: weight)
        let WeightData = HKQuantitySample(type: typeOfBodyMass, quantity: quantity, start: Date(), end: Date())
    
        self.myHealthStore.save(WeightData, withCompletion: {
            (success: Bool, error: Error!) in
            if success {
                NSLog("Success!")
            } else {
                print("error")
            }
        })
        
    
        
//        if Auth.auth().currentUser != nil {
//            let dataStore = Firestore.firestore()
//            dataStore.collection("UserData/\(me.uid)/weightData").addDocument(data: [
//                        "weight": weight,
//                        "sender_id": UUID().uuidString,
//                        "date": Date()
//                    ]) { err in
//                        DispatchQueue.main.async {
//                            if let err = err {
//                                print("Error writing document: \(err)")
//                            } else {
//                              return
//                            }
//                        }
//                    }
//        }

        
    }
    
    //データを取得
    func read() {
        let query = HKSampleQuery(sampleType: typeOfBodyMass, predicate: nil, limit: 1, sortDescriptors: nil) { (query, results, error) in
            if let results = results as? [HKQuantitySample] {
                print(results)
            }
        }
        myHealthStore.execute(query)
    }
    
    // キーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            titleTextField.resignFirstResponder()
            return true
        }
    
    func appear() {
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

    
}
