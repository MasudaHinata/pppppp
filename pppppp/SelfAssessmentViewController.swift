//
//  SelfAssessmentViewController.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/08/12.
//

import UIKit
import Combine

class SelfAssessmentViewController: UIViewController {
    
    var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let task = Task {
            do {
                try await FirebaseClient.shared.validate()
                try await FirebaseClient.shared.checkIconData()
                try await FirebaseClient.shared.checkNameData()
            }
            catch {
                print("Self viewApe", error.localizedDescription)
            }
        }
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
                print("SelfViewCotro good error", error.localizedDescription)
            }
        }
        cancellables.insert(.init { task.cancel() })
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
                print("Self normal error", error.localizedDescription)
            }
        }
        cancellables.insert(.init { task.cancel() })
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
                print("Self bad error", error.localizedDescription)
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
}
