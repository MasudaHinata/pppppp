//
//  SanitasViewController.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/04/23.
//

import UIKit
import HealthKit


class SanitasViewController: UIViewController {
    
    var myHealthStore = HKHealthStore()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let myAuthButton = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
                myAuthButton.backgroundColor = UIColor.orange
                myAuthButton.layer.masksToBounds = true
                myAuthButton.layer.cornerRadius = 20.0
                myAuthButton.setTitle("認証", for: .normal)
                myAuthButton.center = CGPoint(x: self.view.bounds.width/2,y: 200)
                myAuthButton.addTarget(self, action: #selector(ViewController.ClickButton(sender:)), for: .touchUpInside)
                self.view.addSubview(myAuthButton)
        
    }
    
   @IBAction func ClickButton(){
            requestAuthorization()
        }

        private func requestAuthorization(){
            // 読み込みを許可する型.
            let typeOfRead = Set(arrayLiteral:
                HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
                HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!,
                HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.bloodType)!
            )
            // 書き込みを許可する型.
            let typeOfWrite = Set(arrayLiteral:
                HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,
                HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyTemperature)!
            )
            // HealthStoreへのアクセス承認をおこなう.
            myHealthStore.requestAuthorization(toShare: typeOfWrite, read: typeOfRead, completion: { (success, error) in
                if let e = error {
                    print("Error: \(e.localizedDescription)")
                    return
                }
                print(success ? "Success!" : " Failure!")
            })
        }
    }
   
