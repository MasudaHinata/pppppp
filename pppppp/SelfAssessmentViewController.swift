//
//  SelfAssessmentViewController.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/08/12.
//

import UIKit

class SelfAssessmentViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    //自己評価
    @IBAction func goodButton(){
        let task = Task {
            do {
                try await Scorering.shared.getUntilNowPoint()
                let untilNowPoint = Scorering.shared.untilNowPoint
                let sanitasPoints = untilNowPoint + 15
                try await Scorering.shared.firebasePutData(point: sanitasPoints)
            }
            catch {
                //TODO: ERROR Handling
                print("error")
            }
        }
    }
    @IBAction func normalButton(){
        let task = Task {
            do {
                try await Scorering.shared.getUntilNowPoint()
                let untilNowPoint = Scorering.shared.untilNowPoint
                let sanitasPoints = untilNowPoint + 10
                try await Scorering.shared.firebasePutData(point: sanitasPoints)
            }
            catch {
                //TODO: ERROR Handling
                print("error")
            }
        }
    }
    @IBAction func badButton(){
        let task = Task {
            do {
                try await Scorering.shared.getUntilNowPoint()
                let untilNowPoint = Scorering.shared.untilNowPoint
                let sanitasPoints = untilNowPoint + 5
                try await Scorering.shared.firebasePutData(point: sanitasPoints)
                
            }
            catch {
                //TODO: ERROR Handling
                print("error")
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
