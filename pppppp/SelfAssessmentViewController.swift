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
                try await FirebaseClient.shared.getUntilNowPoint()
                let untilNowPoint = FirebaseClient.shared.untilNowPoint
                let sanitasPoints = untilNowPoint + 15
                try await FirebaseClient.shared.firebasePutData(point: sanitasPoints)
                self.performSegue(withIdentifier: "toooooViewController", sender: nil)
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
                try await FirebaseClient.shared.getUntilNowPoint()
                let untilNowPoint = FirebaseClient.shared.untilNowPoint
                let sanitasPoints = untilNowPoint + 10
                try await FirebaseClient.shared.firebasePutData(point: sanitasPoints)
                self.performSegue(withIdentifier: "toooooViewController", sender: nil)
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
                try await FirebaseClient.shared.getUntilNowPoint()
                let untilNowPoint = FirebaseClient.shared.untilNowPoint
                let sanitasPoints = untilNowPoint + 5
                try await FirebaseClient.shared.firebasePutData(point: sanitasPoints)
                self.performSegue(withIdentifier: "toooooViewController", sender: nil)
            }
            catch {
                //TODO: ERROR Handling
                print("error")
            }
        }
    }
}
