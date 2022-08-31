//
//  SelfAssessmentViewController.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/08/12.
//

import UIKit
import Combine

class SelfAssessmentViewController: UIViewController, FirebasePutPointDelegate {
    var cancellables = Set<AnyCancellable>()
    
    @IBOutlet var myIconView: UIImageView! {
        didSet {
            myIconView.layer.cornerRadius = 32
            myIconView.clipsToBounds = true
            myIconView.layer.cornerCurve = .continuous
        }
    }
    
    @IBOutlet var myPointLabelButton: UIButton! {
        didSet {
            var configuration = UIButton.Configuration.filled()
            configuration.title = "---pt"
            configuration.baseBackgroundColor = .init(hex: "92B2D3")
            configuration.cornerStyle = .capsule
            myPointLabelButton.configuration = configuration
        }
    }
    
    @IBOutlet var backgroundView: UIView! {
        didSet {
            backgroundView.layer.cornerRadius = 40
            backgroundView.layer.masksToBounds = true
            backgroundView.layer.cornerCurve = .continuous
        }
    }
    
    @IBOutlet var goodButton: UIButton! {
        didSet {
            goodButton.layer.cornerRadius = 30
            goodButton.layer.cornerCurve = .continuous
            goodButton.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var normalButton: UIButton! {
        didSet {
            normalButton.layer.cornerRadius = 30
            normalButton.layer.cornerCurve = .continuous
            normalButton.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var badButton: UIButton! {
        didSet {
            badButton.layer.cornerRadius = 30
            badButton.layer.cornerCurve = .continuous
            badButton.layer.masksToBounds = true
        }
    }
    
    
    @IBAction func goodButtonPressed(){
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
    @IBAction func normalButtonPressed(){
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
    @IBAction func badButtonPressed(){
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseClient.shared.putPointDelegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let task = Task {
            do {
                try await FirebaseClient.shared.userAuthCheck()
                try await FirebaseClient.shared.checkIconData()
                try await FirebaseClient.shared.checkNameData()
                try await myIconView.kf.setImage(with: FirebaseClient.shared.getMyIconData())
                let userID = try await FirebaseClient.shared.getUserUUID()
                
                var configuration = UIButton.Configuration.filled()
                try await configuration.title = "\(FirebaseClient.shared.getPointDataSum(id: userID))pt"
                configuration.baseBackgroundColor = .init(hex: "92B2D3")
                configuration.cornerStyle = .capsule
                myPointLabelButton.configuration = configuration
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
    func notGetPoint() {
        let alert = UIAlertController(title: "今日の獲得ポイントは0ptです", message: "がんばりましょう", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
