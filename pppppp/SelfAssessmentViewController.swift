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
                try await FirebaseClient.shared.emailVerifyRequiredCheck()
                try await FirebaseClient.shared.checkIconData()
                try await FirebaseClient.shared.checkNameData()
            }
            catch {
                let alert = UIAlertController(title: "エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default)
                alert.addAction(action)
                self.present(alert, animated: true)
                print("SelfViewCotro viewApe", error.localizedDescription)
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    //自己評価
    @IBAction func goodButton(){
        let task = Task {
            do {
                try await FirebaseClient.shared.firebasePutData(point: 15)
            }
            catch {
                let alert = UIAlertController(title: "エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default)
                alert.addAction(action)
                self.present(alert, animated: true)
                print("SelfViewCotro goodButton error:", error.localizedDescription)
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    @IBAction func normalButton(){
        let task = Task {
            do {
                try await FirebaseClient.shared.firebasePutData(point: 10)
            }
            catch {
                let alert = UIAlertController(title: "エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default)
                alert.addAction(action)
                self.present(alert, animated: true)
                print("SelfViewCotro normalButton error", error.localizedDescription)
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    @IBAction func badButton(){
        let task = Task {
            do {
                try await FirebaseClient.shared.firebasePutData(point: 5)
            }
            catch {
                let alert = UIAlertController(title: "エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default)
                alert.addAction(action)
                self.present(alert, animated: true)
                print("SelfViewCotro badButton error", error.localizedDescription)
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    func putPointForFirestore(point: Int) {
        let alert = UIAlertController(title: "ポイントを獲得しました", message: "あなたのポイントは\(point)pt", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            self.performSegue(withIdentifier: "toooooViewController", sender: nil)
        }
        alert.addAction(ok)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
