//
//  SelfAssessmentViewController.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/08/12.
//

import UIKit
import Combine

class SelfAssessmentViewController: UIViewController, FirebasePutPoint {
    var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseClient.shared.putPoint = self
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let task = Task {
            do {
                try await FirebaseClient.shared.userAuthCheck()
                try await FirebaseClient.shared.checkIconData()
                try await FirebaseClient.shared.checkNameData()
            }
            catch {
                print("SelfViewCotro viewApe", error.localizedDescription)
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    //自己評価
    @IBAction func goodButton(){
        let task = Task {
            do {
                try await FirebaseClient.shared.getUntilNowPoint()
                let untilNowPoint = FirebaseClient.shared.untilNowPoint
                let sanitasPoints = untilNowPoint + 15
                try await FirebaseClient.shared.firebaseSelfPutData(point: sanitasPoints)
                self.performSegue(withIdentifier: "toooooViewController", sender: nil)
            }
            catch {
                print("SelfViewCotro goodButton error:", error.localizedDescription)
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
                try await FirebaseClient.shared.firebaseSelfPutData(point: sanitasPoints)
                self.performSegue(withIdentifier: "toooooViewController", sender: nil)
            }
            catch {
                print("SelfViewCotro normalButton error", error.localizedDescription)
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
                try await FirebaseClient.shared.firebaseSelfPutData(point: sanitasPoints)
                self.performSegue(withIdentifier: "toooooViewController", sender: nil)
            }
            catch {
                print("SelfViewCotro badButton error", error.localizedDescription)
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    func putPointForFirestore(point: Int) {
        let alert = UIAlertController(title: "ポイントを獲得しました", message: "あなたのポイントは\(point)pt", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
