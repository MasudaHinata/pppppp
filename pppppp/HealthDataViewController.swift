import UIKit
import HealthKit
import Firebase
import FirebaseFirestore

class HealthDataViewController: UIViewController, UITextFieldDelegate {
    
    let kgUnit: HKUnit = HKUnit(from: "kg")
    
    var myHealthStore = HKHealthStore()
    var typeOfBodyMass = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
    var typeOfStepCount = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
    var typeOfHeight = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!
    var weight: Double!
    let userID = Auth.auth().currentUser!.uid

    @IBOutlet var weightTextField: UITextField!
    
    @IBAction func addButtonPressed() {
        guard let inputWeightText = weightTextField.text else { return }
        guard let inputWeight = Double(inputWeightText) else { return }
        saveWeight(weight: inputWeight)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let toolBar = UIToolbar()
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let okButton: UIBarButtonItem = UIBarButtonItem(title: "OK", style: UIBarButtonItem.Style.plain, target: self, action: #selector(tapOkButton(_:)))
        toolBar.setItems([flexibleItem, okButton, flexibleItem], animated: true)
        toolBar.sizeToFit()
        weightTextField.inputAccessoryView = toolBar
        
        //HealthKit使用の許可
        let types = Set([typeOfBodyMass])
        let readtypes = Set([typeOfBodyMass, typeOfStepCount, typeOfHeight])
        myHealthStore.requestAuthorization(toShare: types, read: readtypes, completion: { success, error in
            print(success)
        })
        
        
        self.weightTextField?.delegate = self
    }
    //体重を保存.
    func saveWeight(weight: Double) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            let quantity = HKQuantity(unit: HKUnit.gramUnit(with: .kilo), doubleValue: weight)
            let WeightData = HKQuantitySample(type: self.typeOfBodyMass, quantity: quantity, start: Date(), end: Date())

            self.myHealthStore.save(WeightData, withCompletion: {
                (success: Bool, error: Error!) in
                if success {
//                    let alert = UIAlertController(title: "記録", message: "体重を記録しました。", preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                    self.present(alert, animated: true, completion: nil)
                    print("HealthKit保存成功!")
                } else {
                    print("HealthKitに保存できませんでした。")
                }
            })
        }
    }
    //身長を取得
    @IBAction func readHeight() {
        readheight()
    }
    func readheight() {
        DispatchQueue.main.async { [self] in
            let query = HKSampleQuery(sampleType: self.typeOfHeight, predicate: nil, limit: Int(1.0), sortDescriptors: nil) { (query, results, error) in
                if results is [HKQuantitySample] {
                    if results is [HKQuantitySample] {
                        // 取得したデータを格納

                        print("身長は\(String(describing: results))")
                    }
                }
            }
            myHealthStore.execute(query)
        }

    }

    //歩数を取得
    @IBAction func readSteps(){
        readsteps()
    }
    func readsteps() {
        let start = Calendar.current.date(byAdding: .day, value: -7, to: Date())
        let end = Date()
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end)

        DispatchQueue.main.async { [self] in
            let query = HKSampleQuery(sampleType: self.typeOfStepCount, predicate: predicate, limit: Int(Float(0.1)), sortDescriptors: nil) { (query, results, error) in
                if results is [HKQuantitySample] {
                    if results is [HKQuantitySample] {
                        // 取得したデータを格納

                        print("歩数は\(String(describing: results))")
                    }
                }
            }
            myHealthStore.execute(query)
        }

    }

    //体重を取得
    @IBAction func readWeight() {
        readweight()
    }
    func readweight() {

        DispatchQueue.main.async { [self] in
            let query = HKSampleQuery(sampleType: self.typeOfBodyMass, predicate: nil, limit: Int(Float(0.1)), sortDescriptors: nil) { (query, results, error) in
                if results is [HKQuantitySample] {
                    if results is [HKQuantitySample] {
                        // 取得したデータを格納
                        let result = results?.last as! HKQuantitySample
                        print(result.quantity.doubleValue(for: .gramUnit(with: .kilo)))
                    }
                }
            }
            myHealthStore.execute(query)
        }
    }

    @objc func tapOkButton(_ sender: UIButton){
        // キーボードを閉じる
        self.view.endEditing(true)
    }
    
}

